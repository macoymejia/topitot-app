import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'models/aac_cell.dart';
import 'models/board_level.dart';
import 'services/board_storage_service.dart';
import 'services/walkthrough_storage_service.dart';
import 'services/tts_service.dart';
import 'widgets/aac_grid.dart';
import 'widgets/board_toolbar.dart';
import 'widgets/cell_editor_dialog.dart';
import 'widgets/sentence_strip.dart';
import 'widgets/walkthrough_overlay.dart';

class AacHomePage extends StatefulWidget {
  const AacHomePage({super.key});

  @override
  State<AacHomePage> createState() => _AacHomePageState();
}

class _AacHomePageState extends State<AacHomePage> {
  final BoardStorageService _boardStorage = BoardStorageService();
  final WalkthroughStorageService _walkthroughStorage =
      WalkthroughStorageService();
  final TtsService _ttsService = TtsService();
  final List<AacCell> _sentence = <AacCell>[];
  final List<BoardLevel> _path = <BoardLevel>[];
  final GlobalKey _sentenceStripKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();
  final GlobalKey _toolbarKey = GlobalKey();
  late BoardLevel _root;

  bool _isLoading = true;
  bool _editMode = false;
  bool _toolbarExpanded = false;
  bool _showWalkthrough = false;
  int _walkthroughStepIndex = 0;
  Rect? _walkthroughTargetRect;

  BoardLevel get _currentBoard => _path.isEmpty ? _root : _path.last;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    _root = await _boardStorage.loadBoard();

    await _ttsService.setup();
    final hasSeenWalkthrough = await _walkthroughStorage.hasSeenWalkthrough();

    if (mounted) {
      setState(() {
        _showWalkthrough = !hasSeenWalkthrough;
        _isLoading = false;
      });
      if (_showWalkthrough) {
        _scheduleWalkthroughTargetUpdate();
      }
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

  GlobalKey? get _currentWalkthroughTargetKey {
    switch (_walkthroughStepIndex) {
      case 0:
        return _sentenceStripKey;
      case 1:
        return _gridKey;
      default:
        return _toolbarKey;
    }
  }

  String get _walkthroughTitle {
    switch (_walkthroughStepIndex) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Build a sentence';
      default:
        return 'Customize the board';
    }
  }

  String get _walkthroughBody {
    switch (_walkthroughStepIndex) {
      case 0:
        return 'Tap Speak to hear the words in your sentence.';
      case 1:
        return 'Tap a word or picture to add it to the strip.';
      default:
        return 'Use Edit Board when a caregiver wants to change cells.';
    }
  }

  bool get _isFinalWalkthroughStep => _walkthroughStepIndex == 2;

  String get _walkthroughPrimaryLabel =>
      _isFinalWalkthroughStep ? 'Get started' : 'Next';

  void _scheduleWalkthroughTargetUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showWalkthrough) {
        return;
      }

      final targetKey = _currentWalkthroughTargetKey;
      final targetRect = targetKey == null ? null : _rectForKey(targetKey);
      if (targetRect != _walkthroughTargetRect) {
        setState(() => _walkthroughTargetRect = targetRect);
      }
    });
  }

  Rect? _rectForKey(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return null;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  Future<void> _dismissWalkthrough() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _showWalkthrough = false;
      _walkthroughTargetRect = null;
    });
    await _walkthroughStorage.markWalkthroughSeen();
  }

  Future<void> _advanceWalkthrough() async {
    if (_isFinalWalkthroughStep) {
      await _dismissWalkthrough();
      return;
    }

    setState(() {
      _walkthroughStepIndex += 1;
      _walkthroughTargetRect = null;
    });
    _scheduleWalkthroughTargetUpdate();
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
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: <Widget>[
                  BoardToolbar(
                    key: _toolbarKey,
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
                    key: _sentenceStripKey,
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
                      key: _gridKey,
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
          if (_showWalkthrough)
            Positioned.fill(
              child: WalkthroughOverlay(
                key: const ValueKey<String>('walkthrough-overlay'),
                targetRect: _walkthroughTargetRect,
                title: _walkthroughTitle,
                body: _walkthroughBody,
                primaryLabel: _walkthroughPrimaryLabel,
                onPrimary: _advanceWalkthrough,
                onSkip: _dismissWalkthrough,
              ),
            ),
        ],
      ),
    );
  }
}
