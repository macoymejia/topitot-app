import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_colors.dart';
import 'theme/app_radius.dart';
import 'theme/app_spacing.dart';
import 'theme/topitot_theme.dart';

void main() {
  runApp(const TopitotApp());
}

const int boardRows = 5;
const int boardColumns = 5;
const int cellsPerPage = boardRows * boardColumns;
const int maxFolderDepth = 4;

class TopitotApp extends StatelessWidget {
  const TopitotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topitot',
      debugShowCheckedModeBanner: false,
      theme: TopitotTheme.light,
      home: const AacHomePage(),
    );
  }
}

class AacHomePage extends StatefulWidget {
  const AacHomePage({super.key});

  @override
  State<AacHomePage> createState() => _AacHomePageState();
}

class _AacHomePageState extends State<AacHomePage> {
  final FlutterTts _tts = FlutterTts();
  final List<AacCell> _sentence = <AacCell>[];
  final List<BoardLevel> _path = <BoardLevel>[];
  late BoardLevel _root;

  bool _isLoading = true;
  bool _editMode = false;
  bool _toolbarExpanded = false;
  List<TtsVoice> _voices = <TtsVoice>[];
  TtsVoice? _selectedVoice;

  BoardLevel get _currentBoard => _path.isEmpty ? _root : _path.last;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBoard = prefs.getString('aac_board');
    final savedVoice = prefs.getString('tts_voice');

    _root =
        savedBoard == null
            ? BoardLevel.starter()
            : BoardLevel.fromJson(
              jsonDecode(savedBoard) as Map<String, dynamic>,
            );

    await _setupSpeech(savedVoice);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupSpeech(String? savedVoice) async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      final voicesResult = await _tts.getVoices;
      final voices = _parseVoices(voicesResult);
      final preferred =
          savedVoice == null
              ? null
              : voices
                  .where((voice) => voice.storageValue == savedVoice)
                  .firstOrNull;

      _voices = voices;
      _selectedVoice = preferred ?? voices.firstOrNull;
      await _applySelectedVoice();
    } on MissingPluginException {
      _voices = <TtsVoice>[];
      _selectedVoice = null;
    } on PlatformException {
      _voices = <TtsVoice>[];
      _selectedVoice = null;
    }
  }

  List<TtsVoice> _parseVoices(dynamic voicesResult) {
    if (voicesResult is! List) {
      return <TtsVoice>[];
    }

    return voicesResult
        .whereType<Map>()
        .map((voice) {
          final name = '${voice['name'] ?? voice['voiceName'] ?? ''}'.trim();
          final locale =
              '${voice['locale'] ?? voice['language'] ?? voice['identifier'] ?? ''}'
                  .trim();
          if (name.isEmpty && locale.isEmpty) {
            return null;
          }
          return TtsVoice(name: name, locale: locale);
        })
        .whereType<TtsVoice>()
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  Future<void> _applySelectedVoice() async {
    final voice = _selectedVoice;
    if (voice == null) {
      return;
    }

    try {
      if (voice.name.isNotEmpty && voice.locale.isNotEmpty) {
        await _tts.setVoice(<String, String>{
          'name': voice.name,
          'locale': voice.locale,
        });
      } else if (voice.locale.isNotEmpty) {
        await _tts.setLanguage(voice.locale);
      }
    } on PlatformException {
      // Some system voices are listed but cannot be selected by every platform.
    }
  }

  Future<void> _saveBoard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aac_board', jsonEncode(_root.toJson()));
  }

  Future<void> _saveVoice() async {
    final prefs = await SharedPreferences.getInstance();
    final voice = _selectedVoice;
    if (voice != null) {
      await prefs.setString('tts_voice', voice.storageValue);
    }
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    try {
      await _tts.stop();
      await _applySelectedVoice();
      await _tts.speak(text.trim());
    } on MissingPluginException {
      debugPrint('Text to speech is not available in this environment: $text');
    } on PlatformException {
      debugPrint('Text to speech failed: $text');
    }
  }

  void _handleCellTap(AacCell cell) {
    if (_editMode) {
      _openCellEditor(cell);
      return;
    }

    if (cell.isBlank) {
      return;
    }

    if (cell.isFolder) {
      cell.children ??= BoardLevel.blank('${cell.label} board');
      setState(() => _path.add(cell.children!));
      return;
    }

    setState(() => _sentence.add(cell));
    _speak(cell.spokenText);
  }

  void _goBack() {
    if (_path.isEmpty) {
      return;
    }

    setState(() => _path.removeLast());
  }

  Future<void> _openCellEditor(AacCell cell) async {
    final updated = await showDialog<AacCell>(
      context: context,
      builder:
          (context) => CellEditorDialog(cell: cell, depth: _path.length + 1),
    );

    if (updated == null) {
      return;
    }

    setState(() => cell.copyFrom(updated));
    await _saveBoard();
  }

  void _clearSentence() {
    setState(_sentence.clear);
  }

  String _sentenceText() {
    return _sentence.map((cell) => cell.spokenText).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: <Widget>[
              _BoardToolbar(
                title: _currentBoard.title,
                depth: _path.length + 1,
                editMode: _editMode,
                expanded: _toolbarExpanded,
                voices: _voices,
                selectedVoice: _selectedVoice,
                onExpandedChanged:
                    (value) => setState(() {
                      _toolbarExpanded = value;
                      if (!value) {
                        _editMode = false;
                      }
                    }),
                onEditModeChanged: (value) => setState(() => _editMode = value),
                onVoiceChanged: (voice) async {
                  setState(() => _selectedVoice = voice);
                  await _applySelectedVoice();
                  await _saveVoice();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _SentenceStrip(
                sentence: _sentence,
                onSpeak: () => _speak(_sentenceText()),
                onClear: _clearSentence,
                onRemoveLast:
                    _sentence.isEmpty
                        ? null
                        : () => setState(() => _sentence.removeLast()),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _AacGrid(
                  cells: _currentBoard.cells,
                  editMode: _editMode,
                  canGoBack: _path.isNotEmpty,
                  onBack: _goBack,
                  onHome:
                      _path.isEmpty
                          ? null
                          : () => setState(() => _path.clear()),
                  onCellTap: _handleCellTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SentenceStrip extends StatelessWidget {
  const _SentenceStrip({
    required this.sentence,
    required this.onSpeak,
    required this.onClear,
    required this.onRemoveLast,
  });

  final List<AacCell> sentence;
  final VoidCallback onSpeak;
  final VoidCallback onClear;
  final VoidCallback? onRemoveLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumBorder,
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                disabledBackgroundColor: AppColors.neutral200,
                foregroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.neutral500,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              ),
              onPressed: sentence.isEmpty ? null : onSpeak,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.volume_up_rounded, size: 32),
                  SizedBox(height: AppSpacing.xxs),
                  Text('Speak'),
                ],
              ),
            ),
          ),
          Container(width: 2, height: 58, color: AppColors.neutral200),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child:
                sentence.isEmpty
                    ? const _EmptySentencePrompt()
                    : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      itemCount: sentence.length,
                      separatorBuilder:
                          (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final cell = sentence[index];
                        return Chip(
                          avatar: Text(
                            cell.symbol,
                            style: const TextStyle(fontSize: 20),
                          ),
                          label: Text(
                            cell.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          backgroundColor: cell.color.withValues(alpha: 0.20),
                          side: BorderSide(color: cell.color, width: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mediumBorder,
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _SentenceUndoButton(
              enabled: sentence.isNotEmpty,
              onRemoveLast: onRemoveLast,
              onClear: onClear,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceUndoButton extends StatelessWidget {
  const _SentenceUndoButton({
    required this.enabled,
    required this.onRemoveLast,
    required this.onClear,
  });

  final bool enabled;
  final VoidCallback? onRemoveLast;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? AppColors.neutral700 : AppColors.neutral500;
    final background =
        enabled ? AppColors.selectedSurface : AppColors.neutral200;

    return Tooltip(
      message: 'Tap to delete one word. Double tap or hold to clear.',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Delete one word, or clear all words',
        hint: 'Tap once to delete one word. Double tap or hold to clear.',
        child: Material(
          color: background,
          borderRadius: AppRadius.mediumBorder,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onRemoveLast : null,
            onDoubleTap: enabled ? onClear : null,
            onLongPress: enabled ? onClear : null,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(
                Icons.backspace_outlined,
                color: foreground,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySentencePrompt extends StatelessWidget {
  const _EmptySentencePrompt();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 34),
        SizedBox(width: AppSpacing.md),
        Text(
          'Choose words',
          style: TextStyle(
            color: AppColors.neutral700,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BoardToolbar extends StatelessWidget {
  const _BoardToolbar({
    required this.title,
    required this.depth,
    required this.editMode,
    required this.expanded,
    required this.voices,
    required this.selectedVoice,
    required this.onExpandedChanged,
    required this.onEditModeChanged,
    required this.onVoiceChanged,
  });

  final String title;
  final int depth;
  final bool editMode;
  final bool expanded;
  final List<TtsVoice> voices;
  final TtsVoice? selectedVoice;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<bool> onEditModeChanged;
  final ValueChanged<TtsVoice?> onVoiceChanged;

  @override
  Widget build(BuildContext context) {
    const toolbarSlotHeight = 96.0;
    final toolbarHeight = expanded ? toolbarSlotHeight : 60.0;
    final toolbarPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: expanded ? AppSpacing.md : AppSpacing.xs,
    );

    return SizedBox(
      height: toolbarSlotHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: toolbarHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: editMode ? AppColors.editSurface : AppColors.surface,
              borderRadius: AppRadius.mediumBorder,
              border: Border.all(
                color: editMode ? AppColors.secondary : AppColors.neutral200,
                width: 2,
              ),
            ),
            child: Padding(
              padding: toolbarPadding,
              child:
                  expanded
                      ? Row(
                        children: <Widget>[
                          _ToolbarIdentity(title: title),
                          SizedBox(
                            width: 230,
                            child: DropdownButtonFormField<TtsVoice>(
                              isExpanded: true,
                              value: selectedVoice,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.record_voice_over_rounded,
                                ),
                                labelText: 'Voice',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items:
                                  voices
                                      .map(
                                        (voice) => DropdownMenuItem<TtsVoice>(
                                          value: voice,
                                          child: Text(
                                            voice.label,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              hint: const Text('Default voice'),
                              onChanged: voices.isEmpty ? null : onVoiceChanged,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          FilledButton.tonalIcon(
                            onPressed: () => onEditModeChanged(!editMode),
                            icon: Icon(
                              editMode
                                  ? Icons.edit_rounded
                                  : Icons.touch_app_rounded,
                            ),
                            label: Text(editMode ? 'Edit' : 'Use'),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton.filledTonal(
                            tooltip: 'Collapse toolbar',
                            onPressed: () => onExpandedChanged(false),
                            icon: const Icon(Icons.expand_less_rounded),
                          ),
                        ],
                      )
                      : Row(
                        children: <Widget>[
                          _ToolbarIdentity(title: title),
                          const SizedBox(width: AppSpacing.lg),
                          _LevelDots(depth: depth),
                          const Spacer(),
                          SizedBox.square(
                            dimension: 48,
                            child: IconButton.filledTonal(
                              tooltip: 'Expand toolbar',
                              onPressed: () => onExpandedChanged(true),
                              icon: const Icon(Icons.expand_more_rounded),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIdentity extends StatelessWidget {
  const _ToolbarIdentity({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          const _AppIconMark(size: 36),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.neutral700,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelDots extends StatelessWidget {
  const _LevelDots({required this.depth});

  final int depth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(maxFolderDepth, (index) {
        final active = index < depth;
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: 22,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.neutral200,
              borderRadius: AppRadius.mediumBorder,
            ),
          ),
        );
      }),
    );
  }
}

class _AppIconMark extends StatelessWidget {
  const _AppIconMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.selectedSurface,
        borderRadius: AppRadius.mediumBorder,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Icon(
        Icons.record_voice_over_rounded,
        color: AppColors.primary,
        size: size * 0.58,
      ),
    );
  }
}

class _AacGrid extends StatelessWidget {
  const _AacGrid({
    required this.cells,
    required this.editMode,
    required this.canGoBack,
    required this.onBack,
    required this.onHome,
    required this.onCellTap,
  });

  final List<AacCell> cells;
  final bool editMode;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback? onHome;
  final ValueChanged<AacCell> onCellTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.gridGap;
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;
        final tileWidth =
            (gridWidth - (boardColumns - 1) * spacing) / boardColumns;
        final tileHeight = (gridHeight - (boardRows - 1) * spacing) / boardRows;
        final uncappedAspectRatio =
            tileHeight <= 0 ? 1.0 : tileWidth / tileHeight;
        final aspectRatio =
            uncappedAspectRatio < 0.72 ? 0.72 : uncappedAspectRatio;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardColumns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: cellsPerPage,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _GridNavigationTile(
                key: const ValueKey<String>('grid-back-cell'),
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                enabled: canGoBack,
                onTap: onBack,
              );
            }
            if (index == 1) {
              return _GridNavigationTile(
                key: const ValueKey<String>('grid-home-cell'),
                label: 'Home',
                icon: Icons.home_rounded,
                enabled: onHome != null,
                onTap: onHome,
              );
            }

            final cell = cells[index - 2];
            return _AacTile(
              key: ValueKey<String>('aac-cell-$index'),
              cell: cell,
              editMode: editMode,
              onTap: () => onCellTap(cell),
            );
          },
        );
      },
    );
  }
}

class _GridNavigationTile extends StatelessWidget {
  const _GridNavigationTile({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? AppColors.neutral700 : AppColors.neutral500;
    final background =
        enabled ? AppColors.selectedSurface : AppColors.disabledSurface;
    final border = enabled ? AppColors.primary : AppColors.neutral200;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: background,
        borderRadius: AppRadius.mediumBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 3),
              borderRadius: AppRadius.mediumBorder,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 112;
                final iconSize =
                    constraints.maxHeight * (compact ? 0.34 : 0.38);
                final labelSize =
                    constraints.maxHeight * (compact ? 0.14 : 0.16);

                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      compact ? AppSpacing.xs : AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          icon,
                          color: foreground,
                          size: iconSize.clamp(24, 54),
                        ),
                        SizedBox(
                          height: compact ? AppSpacing.xxs : AppSpacing.xs,
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: foreground,
                            fontSize: labelSize.clamp(11, 20),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AacTile extends StatelessWidget {
  const _AacTile({
    super.key,
    required this.cell,
    required this.editMode,
    required this.onTap,
  });

  final AacCell cell;
  final bool editMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        cell.color.computeLuminance() > 0.45
            ? AppColors.neutral900
            : AppColors.surface;
    final tileColor =
        cell.isBlank && !editMode ? AppColors.disabledSurface : cell.color;
    final canTap = editMode || !cell.isBlank;
    final borderColor =
        editMode
            ? AppColors.neutral900
            : cell.isFolder
            ? AppColors.neutral900.withValues(alpha: 0.42)
            : AppColors.transparent;

    return Semantics(
      button: canTap,
      enabled: canTap,
      label:
          cell.isFolder
              ? 'Open ${cell.label}'
              : cell.isBlank
              ? 'Empty AAC cell'
              : 'Say ${cell.label}',
      child: Material(
        color: tileColor,
        borderRadius: AppRadius.mediumBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canTap ? onTap : null,
          splashColor: AppColors.surface.withValues(alpha: 0.35),
          highlightColor: AppColors.neutral900.withValues(alpha: 0.08),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: editMode || cell.isFolder ? 3 : 0,
              ),
              borderRadius: AppRadius.mediumBorder,
            ),
            child: Stack(
              children: <Widget>[
                if (cell.isBlank && !editMode)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.disabledSurface,
                        backgroundBlendMode: BlendMode.srcOver,
                      ),
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 112;
                    final showContent = !cell.isBlank || editMode;
                    final shortestSide =
                        constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                    final symbolBoxHeight =
                        shortestSide * (compact ? 0.66 : 0.62);
                    final labelSize =
                        compact ? constraints.maxHeight * 0.14 : 21.0;

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? AppSpacing.xs : AppSpacing.md,
                          compact ? AppSpacing.xs : AppSpacing.md,
                          cell.isFolder ? 32 : (compact ? 6 : AppSpacing.md),
                          compact ? AppSpacing.xs : AppSpacing.md,
                        ),
                        child:
                            showContent
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: symbolBoxHeight,
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          cell.symbol,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: compact ? 1 : AppSpacing.sm,
                                    ),
                                    Flexible(
                                      child: Text(
                                        cell.label,
                                        maxLines: compact ? 1 : 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              cell.isBlank
                                                  ? AppColors.neutral500
                                                  : foreground,
                                          fontSize: labelSize.clamp(13, 20),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : const SizedBox.expand(),
                      ),
                    );
                  },
                ),
                if (cell.isFolder)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.16),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.medium),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: foreground,
                        size: 30,
                      ),
                    ),
                  ),
                if (editMode)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _TileCue(
                      icon:
                          cell.isBlank ? Icons.add_rounded : Icons.edit_rounded,
                      foreground: foreground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileCue extends StatelessWidget {
  const _TileCue({required this.icon, required this.foreground});

  final IconData icon;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.78),
        borderRadius: AppRadius.mediumBorder,
      ),
      child: Icon(icon, color: foreground, size: 20),
    );
  }
}

class CellEditorDialog extends StatefulWidget {
  const CellEditorDialog({super.key, required this.cell, required this.depth});

  final AacCell cell;
  final int depth;

  @override
  State<CellEditorDialog> createState() => _CellEditorDialogState();
}

class _CellEditorDialogState extends State<CellEditorDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _spokenTextController;
  late final TextEditingController _symbolController;
  late Color _color;
  late bool _isFolder;

  static const List<Color> _swatches = AppColors.cellSwatches;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.cell.label);
    _spokenTextController = TextEditingController(text: widget.cell.spokenText);
    _symbolController = TextEditingController(text: widget.cell.symbol);
    _color = widget.cell.color;
    _isFolder = widget.cell.isFolder;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _spokenTextController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canCreateFolder = widget.depth < maxFolderDepth;

    return AlertDialog(
      title: const Text('Customize cell'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Displayed word',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _spokenTextController,
                decoration: const InputDecoration(
                  labelText: 'Audio playback text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _symbolController,
                decoration: const InputDecoration(
                  labelText: 'Picture, icon, or visual symbol',
                  helperText: 'Use an emoji, short text, or icon-like symbol.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Open another board level'),
                subtitle: Text(
                  canCreateFolder
                      ? 'Folders can go up to level $maxFolderDepth.'
                      : 'This is already the deepest level.',
                ),
                value: _isFolder,
                onChanged:
                    canCreateFolder
                        ? (value) => setState(() => _isFolder = value)
                        : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _swatches.map((color) {
                        final isSelected =
                            color.toARGB32() == _color.toARGB32();
                        return InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          onTap: () => setState(() => _color = color),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.neutral900
                                        : AppColors.transparent,
                                width: 3,
                              ),
                            ),
                            child:
                                isSelected
                                    ? const Icon(Icons.check_rounded)
                                    : null,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            final edited =
                widget.cell.clone()
                  ..label =
                      _labelController.text.trim().isEmpty
                          ? 'Empty'
                          : _labelController.text.trim()
                  ..spokenText =
                      _spokenTextController.text.trim().isEmpty
                          ? _labelController.text.trim()
                          : _spokenTextController.text.trim()
                  ..symbol =
                      _symbolController.text.trim().isEmpty
                          ? '...'
                          : _symbolController.text.trim()
                  ..color = _color
                  ..kind = _isFolder ? CellKind.folder : CellKind.speak;

            if (_isFolder && edited.children == null) {
              edited.children = BoardLevel.blank('${edited.label} board');
            }
            if (!_isFolder) {
              edited.children = null;
            }

            Navigator.pop(context, edited);
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

enum CellKind { speak, folder }

class BoardLevel {
  BoardLevel({required this.title, required this.cells});

  String title;
  List<AacCell> cells;

  factory BoardLevel.blank(String title) {
    return BoardLevel(
      title: title,
      cells: List<AacCell>.generate(
        cellsPerPage,
        (index) => AacCell.blank(index),
      ),
    );
  }

  factory BoardLevel.starter() {
    final board = BoardLevel.blank('Topitot');
    board.cells = <AacCell>[
      AacCell.speak('I', 'I', 'I', AppColors.blueSoft),
      AacCell.speak('want', 'want', '🤲', AppColors.yellowSoft),
      AacCell.speak('eat', 'eat', '🍽️', AppColors.coralSoft),
      AacCell.speak('drink', 'drink', '🥤', AppColors.greenSoft),
      AacCell.speak('more', 'more', '+', AppColors.lavender),
      AacCell.speak('finished', 'finished', '✓', AppColors.slateSoft),
      AacCell.folder(
        'Food',
        'Food',
        '🍎',
        AppColors.coralSoft,
        BoardLevel(
          title: 'Food',
          cells: <AacCell>[
            AacCell.speak('rice', 'rice', '🍚', AppColors.yellowSoft),
            AacCell.speak('bread', 'bread', '🍞', AppColors.yellowSoft),
            AacCell.speak('banana', 'banana', '🍌', AppColors.yellowSoft),
            AacCell.speak('apple', 'apple', '🍎', AppColors.coralSoft),
            AacCell.speak('chicken', 'chicken', '🍗', AppColors.coralSoft),
            AacCell.speak('egg', 'egg', '🥚', AppColors.yellowSoft),
            ...List<AacCell>.generate(
              cellsPerPage - 6,
              (index) => AacCell.blank(index + 6),
            ),
          ],
        ),
      ),
      AacCell.folder(
        'Feelings',
        'Feelings',
        '🙂',
        AppColors.lavender,
        BoardLevel(
          title: 'Feelings',
          cells: <AacCell>[
            AacCell.speak('happy', 'happy', '😊', AppColors.yellowSoft),
            AacCell.speak('sad', 'sad', '😢', AppColors.blueSoft),
            AacCell.speak('angry', 'angry', '😠', AppColors.coralSoft),
            AacCell.speak('tired', 'tired', '😴', AppColors.slateSoft),
            AacCell.speak('hurt', 'hurt', '🤕', AppColors.pinkSoft),
            AacCell.speak('scared', 'scared', '😟', AppColors.lavender),
            ...List<AacCell>.generate(
              cellsPerPage - 6,
              (index) => AacCell.blank(index + 6),
            ),
          ],
        ),
      ),
      AacCell.folder(
        'People',
        'People',
        '👨‍👩‍👧',
        AppColors.limeSoft,
        BoardLevel.blank('People'),
      ),
      AacCell.speak('yes', 'yes', '✓', AppColors.greenSoft),
      AacCell.speak('no', 'no', '✕', AppColors.pinkSoft),
      AacCell.speak('help', 'help', '🆘', AppColors.coralSoft),
      AacCell.speak('please', 'please', '🙏', AppColors.blueSoft),
      AacCell.speak('thank you', 'thank you', '⭐', AppColors.yellowSoft),
      AacCell.speak('stop', 'stop', '✋', AppColors.pinkSoft),
      AacCell.folder(
        'Places',
        'Places',
        '🏠',
        AppColors.slateSoft,
        BoardLevel.blank('Places'),
      ),
      AacCell.folder(
        'Actions',
        'Actions',
        '🏃',
        AppColors.blueSoft,
        BoardLevel.blank('Actions'),
      ),
      AacCell.speak('bathroom', 'bathroom', '🚽', AppColors.greenSoft),
      ...List<AacCell>.generate(
        cellsPerPage - 18,
        (index) => AacCell.blank(index + 18),
      ),
    ];
    return board;
  }

  factory BoardLevel.fromJson(Map<String, dynamic> json) {
    final rawCells = json['cells'];
    final parsedCells =
        rawCells is List
            ? rawCells
                .whereType<Map<String, dynamic>>()
                .map(AacCell.fromJson)
                .toList()
            : <AacCell>[];

    return BoardLevel(
      title: '${json['title'] ?? 'AAC board'}',
      cells: _normalizeCells(parsedCells),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'cells': cells.map((cell) => cell.toJson()).toList(),
    };
  }

  static List<AacCell> _normalizeCells(List<AacCell> cells) {
    final normalized = List<AacCell>.from(cells.take(cellsPerPage));
    while (normalized.length < cellsPerPage) {
      normalized.add(AacCell.blank(normalized.length));
    }
    return normalized;
  }
}

class AacCell {
  AacCell({
    required this.label,
    required this.spokenText,
    required this.symbol,
    required this.color,
    required this.kind,
    this.children,
  });

  String label;
  String spokenText;
  String symbol;
  Color color;
  CellKind kind;
  BoardLevel? children;

  bool get isFolder => kind == CellKind.folder;
  bool get isBlank => label == 'Empty';

  factory AacCell.blank(int index) {
    return AacCell(
      label: 'Empty',
      spokenText: '',
      symbol: '+',
      color: AppColors.emptyCell,
      kind: CellKind.speak,
    );
  }

  factory AacCell.speak(
    String label,
    String spokenText,
    String symbol,
    Color color,
  ) {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      color: color,
      kind: CellKind.speak,
    );
  }

  factory AacCell.folder(
    String label,
    String spokenText,
    String symbol,
    Color color,
    BoardLevel children,
  ) {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      color: color,
      kind: CellKind.folder,
      children: children,
    );
  }

  factory AacCell.fromJson(Map<String, dynamic> json) {
    return AacCell(
      label: '${json['label'] ?? 'Empty'}',
      spokenText: '${json['spokenText'] ?? ''}',
      symbol: '${json['symbol'] ?? '+'}',
      color: Color(
        json['color'] is int ? json['color'] as int : AppColors.emptyCellArgb,
      ),
      kind: json['kind'] == 'folder' ? CellKind.folder : CellKind.speak,
      children:
          json['children'] is Map<String, dynamic>
              ? BoardLevel.fromJson(json['children'] as Map<String, dynamic>)
              : null,
    );
  }

  AacCell clone() {
    return AacCell(
      label: label,
      spokenText: spokenText,
      symbol: symbol,
      color: color,
      kind: kind,
      children: children,
    );
  }

  void copyFrom(AacCell other) {
    label = other.label;
    spokenText = other.spokenText;
    symbol = other.symbol;
    color = other.color;
    kind = other.kind;
    children = other.children;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'spokenText': spokenText,
      'symbol': symbol,
      'color': color.toARGB32(),
      'kind': kind.name,
      'children': children?.toJson(),
    };
  }
}

class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  String get label {
    if (name.isEmpty) {
      return locale;
    }
    if (locale.isEmpty) {
      return name;
    }
    return '$name ($locale)';
  }

  String get storageValue =>
      jsonEncode(<String, String>{'name': name, 'locale': locale});

  @override
  bool operator ==(Object other) {
    return other is TtsVoice && other.name == name && other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(name, locale);
}
