import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TopitotApp());
}

const int boardRows = 3;
const int boardColumns = 6;
const int cellsPerPage = boardRows * boardColumns;
const int maxFolderDepth = 4;

class TopitotApp extends StatelessWidget {
  const TopitotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topitot AAC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontWeight: FontWeight.w800),
          bodyLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _SentenceStrip(
                sentence: _sentence,
                onSpeak: () => _speak(_sentenceText()),
                onClear: _clearSentence,
                onRemoveLast:
                    _sentence.isEmpty
                        ? null
                        : () => setState(() => _sentence.removeLast()),
              ),
              const SizedBox(height: 12),
              _BoardToolbar(
                title: _currentBoard.title,
                depth: _path.length + 1,
                canGoBack: _path.isNotEmpty,
                editMode: _editMode,
                voices: _voices,
                selectedVoice: _selectedVoice,
                onBack: _goBack,
                onEditModeChanged: (value) => setState(() => _editMode = value),
                onVoiceChanged: (voice) async {
                  setState(() => _selectedVoice = voice);
                  await _applySelectedVoice();
                  await _saveVoice();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _AacGrid(
                  cells: _currentBoard.cells,
                  editMode: _editMode,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 88,
            height: double.infinity,
            child: IconButton.filled(
              tooltip: 'Play sentence',
              onPressed: sentence.isEmpty ? null : onSpeak,
              icon: const Icon(Icons.play_arrow_rounded, size: 42),
            ),
          ),
          Expanded(
            child:
                sentence.isEmpty
                    ? const Text(
                      'Choose words',
                      style: TextStyle(
                        color: Color(0xFF5E6B7A),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                    : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: sentence.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cell = sentence[index];
                        return Chip(
                          avatar: Text(cell.symbol),
                          label: Text(
                            cell.label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          backgroundColor: cell.color.withValues(alpha: 0.18),
                          side: BorderSide(color: cell.color),
                        );
                      },
                    ),
          ),
          SizedBox(
            width: 56,
            child: IconButton(
              tooltip: 'Remove last word',
              onPressed: onRemoveLast,
              icon: const Icon(Icons.backspace_outlined),
            ),
          ),
          SizedBox(
            width: 56,
            child: IconButton(
              tooltip: 'Clear sentence',
              onPressed: sentence.isEmpty ? null : onClear,
              icon: const Icon(Icons.clear_all_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardToolbar extends StatelessWidget {
  const _BoardToolbar({
    required this.title,
    required this.depth,
    required this.canGoBack,
    required this.editMode,
    required this.voices,
    required this.selectedVoice,
    required this.onBack,
    required this.onEditModeChanged,
    required this.onVoiceChanged,
  });

  final String title;
  final int depth;
  final bool canGoBack;
  final bool editMode;
  final List<TtsVoice> voices;
  final TtsVoice? selectedVoice;
  final VoidCallback onBack;
  final ValueChanged<bool> onEditModeChanged;
  final ValueChanged<TtsVoice?> onVoiceChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Level $depth of $maxFolderDepth',
                style: const TextStyle(
                  color: Color(0xFF5E6B7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 280,
          child: DropdownButtonFormField<TtsVoice>(
            isExpanded: true,
            value: selectedVoice,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.record_voice_over_rounded),
              labelText: 'System voice',
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
        const SizedBox(width: 12),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.touch_app_rounded),
              label: Text('Use'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.edit_rounded),
              label: Text('Edit'),
            ),
          ],
          selected: <bool>{editMode},
          onSelectionChanged: (selection) {
            onEditModeChanged(selection.first);
          },
        ),
        const SizedBox(width: 12),
        SizedBox.square(
          dimension: 56,
          child: IconButton.filledTonal(
            tooltip: 'Back',
            onPressed: canGoBack ? onBack : null,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
      ],
    );
  }
}

class _AacGrid extends StatelessWidget {
  const _AacGrid({
    required this.cells,
    required this.editMode,
    required this.onCellTap,
  });

  final List<AacCell> cells;
  final bool editMode;
  final ValueChanged<AacCell> onCellTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: boardColumns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.18,
      ),
      itemCount: cellsPerPage,
      itemBuilder: (context, index) {
        final cell = cells[index];
        return _AacTile(
          cell: cell,
          editMode: editMode,
          onTap: () => onCellTap(cell),
        );
      },
    );
  }
}

class _AacTile extends StatelessWidget {
  const _AacTile({
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
            ? const Color(0xFF17202A)
            : Colors.white;

    return Semantics(
      button: true,
      label: cell.isBlank ? 'Empty AAC cell' : cell.label,
      child: Material(
        color: cell.isBlank ? Colors.white : cell.color,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: editMode ? const Color(0xFF17202A) : Colors.transparent,
                width: editMode ? 3 : 0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 112;
                    final symbolSize =
                        compact ? constraints.maxHeight * 0.34 : 46.0;
                    final labelSize =
                        compact ? constraints.maxHeight * 0.16 : 20.0;

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 6 : 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              cell.symbol,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: symbolSize),
                            ),
                            SizedBox(height: compact ? 3 : 8),
                            Text(
                              cell.label,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    cell.isBlank
                                        ? const Color(0xFF5E6B7A)
                                        : foreground,
                                fontSize: labelSize.clamp(13, 20),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (cell.isFolder)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.folder_rounded,
                      color: foreground.withValues(alpha: 0.92),
                    ),
                  ),
                if (editMode)
                  const Positioned(
                    left: 8,
                    top: 8,
                    child: Icon(Icons.edit_rounded, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
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

  static const List<Color> _swatches = <Color>[
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFFBA68C8),
    Color(0xFF90A4AE),
    Color(0xFFF06292),
    Color(0xFFAED581),
  ];

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
              const SizedBox(height: 12),
              TextField(
                controller: _spokenTextController,
                decoration: const InputDecoration(
                  labelText: 'Audio playback text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _symbolController,
                decoration: const InputDecoration(
                  labelText: 'Picture, icon, or visual symbol',
                  helperText: 'Use an emoji, short text, or icon-like symbol.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 12),
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
                          borderRadius: BorderRadius.circular(999),
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
                                        ? const Color(0xFF17202A)
                                        : Colors.transparent,
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
    final board = BoardLevel.blank('Topitot AAC');
    board.cells = <AacCell>[
      AacCell.speak('I', 'I', 'I', const Color(0xFF4FC3F7)),
      AacCell.speak('want', 'want', '🤲', const Color(0xFFFFD54F)),
      AacCell.speak('eat', 'eat', '🍽️', const Color(0xFFFF8A65)),
      AacCell.speak('drink', 'drink', '🥤', const Color(0xFF81C784)),
      AacCell.speak('more', 'more', '+', const Color(0xFFBA68C8)),
      AacCell.speak('finished', 'finished', '✓', const Color(0xFF90A4AE)),
      AacCell.folder(
        'Food',
        'Food',
        '🍎',
        const Color(0xFFFF8A65),
        BoardLevel(
          title: 'Food',
          cells: <AacCell>[
            AacCell.speak('rice', 'rice', '🍚', const Color(0xFFFFD54F)),
            AacCell.speak('bread', 'bread', '🍞', const Color(0xFFFFD54F)),
            AacCell.speak('banana', 'banana', '🍌', const Color(0xFFFFD54F)),
            AacCell.speak('apple', 'apple', '🍎', const Color(0xFFFF8A65)),
            AacCell.speak('chicken', 'chicken', '🍗', const Color(0xFFFF8A65)),
            AacCell.speak('egg', 'egg', '🥚', const Color(0xFFFFD54F)),
            ...List<AacCell>.generate(12, (index) => AacCell.blank(index + 6)),
          ],
        ),
      ),
      AacCell.folder(
        'Feelings',
        'Feelings',
        '🙂',
        const Color(0xFFBA68C8),
        BoardLevel(
          title: 'Feelings',
          cells: <AacCell>[
            AacCell.speak('happy', 'happy', '😊', const Color(0xFFFFD54F)),
            AacCell.speak('sad', 'sad', '😢', const Color(0xFF4FC3F7)),
            AacCell.speak('angry', 'angry', '😠', const Color(0xFFFF8A65)),
            AacCell.speak('tired', 'tired', '😴', const Color(0xFF90A4AE)),
            AacCell.speak('hurt', 'hurt', '🤕', const Color(0xFFF06292)),
            AacCell.speak('scared', 'scared', '😟', const Color(0xFFBA68C8)),
            ...List<AacCell>.generate(12, (index) => AacCell.blank(index + 6)),
          ],
        ),
      ),
      AacCell.folder(
        'People',
        'People',
        '👨‍👩‍👧',
        const Color(0xFFAED581),
        BoardLevel.blank('People'),
      ),
      AacCell.speak('yes', 'yes', '✓', const Color(0xFF81C784)),
      AacCell.speak('no', 'no', '✕', const Color(0xFFF06292)),
      AacCell.speak('help', 'help', '🆘', const Color(0xFFFF8A65)),
      AacCell.speak('please', 'please', '🙏', const Color(0xFF4FC3F7)),
      AacCell.speak('thank you', 'thank you', '⭐', const Color(0xFFFFD54F)),
      AacCell.speak('stop', 'stop', '✋', const Color(0xFFF06292)),
      AacCell.folder(
        'Places',
        'Places',
        '🏠',
        const Color(0xFF90A4AE),
        BoardLevel.blank('Places'),
      ),
      AacCell.folder(
        'Actions',
        'Actions',
        '🏃',
        const Color(0xFF4FC3F7),
        BoardLevel.blank('Actions'),
      ),
      AacCell.speak('bathroom', 'bathroom', '🚽', const Color(0xFF81C784)),
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
      color: const Color(0xFFE8EDF3),
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
      color: Color(json['color'] is int ? json['color'] as int : 0xFFE8EDF3),
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
