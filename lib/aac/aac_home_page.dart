import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'controllers/aac_controller.dart';
import 'models/aac_cell.dart';
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
  late final AacController _controller;

  final GlobalKey _sentenceStripKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();
  final GlobalKey _toolbarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AacController();
    _controller.addListener(_onControllerChanged);
    _initApp();
  }

  Future<void> _initApp() async {
    await _controller.loadApp();
    if (mounted && _controller.showWalkthrough) {
      _scheduleWalkthroughTargetUpdate();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted && _controller.showWalkthrough) {
      _scheduleWalkthroughTargetUpdate();
    }
  }

  GlobalKey? get _currentWalkthroughTargetKey {
    switch (_controller.walkthroughStepIndex) {
      case 0:
        return _sentenceStripKey;
      case 1:
        return _gridKey;
      default:
        return _toolbarKey;
    }
  }

  String get _walkthroughTitle {
    switch (_controller.walkthroughStepIndex) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Build a sentence';
      default:
        return 'Customize the board';
    }
  }

  String get _walkthroughBody {
    switch (_controller.walkthroughStepIndex) {
      case 0:
        return 'Tap Speak to hear the words in your sentence.';
      case 1:
        return 'Tap a word or picture to add it to the strip.';
      default:
        return 'Use Edit Board when a caregiver wants to change cells.';
    }
  }

  bool get _isFinalWalkthroughStep => _controller.walkthroughStepIndex == 2;

  String get _walkthroughPrimaryLabel =>
      _isFinalWalkthroughStep ? 'Get started' : 'Next';

  void _scheduleWalkthroughTargetUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.showWalkthrough) {
        return;
      }

      final targetKey = _currentWalkthroughTargetKey;
      final targetRect = targetKey == null ? null : _rectForKey(targetKey);
      _controller.setWalkthroughTargetRect(targetRect);
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

  Future<void> _handleCellTap(AacCell cell) async {
    if (_controller.editMode && !cell.label.startsWith('Back') && cell.label != 'Back' && cell.label != 'Home') {
      await _openCellEditor(cell);
      return;
    }
    _controller.handleCellTap(cell);
  }

  Future<void> _openCellEditor(AacCell cell) async {
    final updated = await showDialog<AacCell>(
      context: context,
      builder:
          (context) => CellEditorDialog(
            cell: cell,
            depth: _controller.pathDepth,
          ),
    );

    if (updated == null || !mounted) {
      return;
    }

    cell.copyFrom(updated);
    await _controller.saveBoard();
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Board?'),
            content: const Text(
              'This will restore the default starting words and colors. Your custom edits will be replaced.',
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

    if (confirm == true && mounted) {
      await _controller.resetBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
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
                        depth: _controller.pathDepth,
                        editMode: _controller.editMode,
                        expanded: _controller.toolbarExpanded,
                        onExpandedChanged: _controller.setToolbarExpanded,
                        onEditModeChanged: _controller.setEditMode,
                        onReset: _handleReset,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SentenceStrip(
                        key: _sentenceStripKey,
                        sentence: _controller.sentence,
                        onSpeak: () => _controller.speak(_controller.sentenceText),
                        onClear: _controller.clearSentence,
                        onRemoveLast:
                            _controller.sentence.isEmpty
                                ? null
                                : _controller.removeLastSentenceWord,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: AacGrid(
                          key: _gridKey,
                          cells: _controller.currentBoard.cells,
                          editMode: _controller.editMode,
                          canGoBack: _controller.canGoBack,
                          onHome:
                              _controller.canGoBack ? _controller.goHome : null,
                          onCellTap: _handleCellTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_controller.showWalkthrough)
                Positioned.fill(
                  child: WalkthroughOverlay(
                    key: const ValueKey<String>('walkthrough-overlay'),
                    targetRect: _controller.walkthroughTargetRect,
                    title: _walkthroughTitle,
                    body: _walkthroughBody,
                    primaryLabel: _walkthroughPrimaryLabel,
                    onPrimary: _controller.advanceWalkthrough,
                    onSkip: _controller.dismissWalkthrough,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
