import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'models/aac_cell.dart';
import 'models/board_level.dart';
import 'services/board_storage_service.dart';
import 'services/tts_service.dart';
import 'widgets/aac_grid.dart';
import 'widgets/board_toolbar.dart';
import 'widgets/cell_editor_dialog.dart';
import 'widgets/sentence_strip.dart';

class AacHomePage extends StatefulWidget {
  const AacHomePage({super.key});

  @override
  State<AacHomePage> createState() => _AacHomePageState();
}

class _AacHomePageState extends State<AacHomePage> {
  final BoardStorageService _boardStorage = BoardStorageService();
  final TtsService _ttsService = TtsService();
  final List<AacCell> _sentence = <AacCell>[];
  final List<BoardLevel> _path = <BoardLevel>[];
  late BoardLevel _root;

  bool _isLoading = true;
  bool _editMode = false;
  bool _toolbarExpanded = false;

  BoardLevel get _currentBoard => _path.isEmpty ? _root : _path.last;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    _root = await _boardStorage.loadBoard();

    await _ttsService.setup();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBoard() async {
    await _boardStorage.saveBoard(_root);
  }

  Future<void> _speak(String text) async {
    await _ttsService.speak(text);
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

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Board?'),
            content: const Text(
              'This will restore the default speech-delayed optimized starting words and colors. Your custom edits will be replaced.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _root = BoardLevel.starter();
        _path.clear();
        _editMode = false;
        _toolbarExpanded = false;
      });
      await _saveBoard();
    }
  }

  String _sentenceText() {
    return _sentence.map((cell) => cell.spokenText).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: <Widget>[
              BoardToolbar(
                title: _currentBoard.title,
                depth: _path.length + 1,
                editMode: _editMode,
                expanded: _toolbarExpanded,
                onExpandedChanged:
                    (value) => setState(() {
                      _toolbarExpanded = value;
                      if (!value) {
                        _editMode = false;
                      }
                    }),
                onEditModeChanged: (value) => setState(() => _editMode = value),
                onReset: _handleReset,
              ),
              const SizedBox(height: AppSpacing.sm),
              SentenceStrip(
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
                child: AacGrid(
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
