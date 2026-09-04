import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../models/aac_cell.dart';
import 'cell_visual.dart';

class SentenceStrip extends StatefulWidget {
  const SentenceStrip({
    super.key,
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
  State<SentenceStrip> createState() => _SentenceStripState();
}

class _SentenceStripState extends State<SentenceStrip> {
  static const double _stripHeight = 156;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollAndFocusLatest(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollAndFocusLatest() {
    if (!mounted || widget.sentence.isEmpty) {
      return;
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(SentenceStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sentence.length != oldWidget.sentence.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollAndFocusLatest(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: _stripHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mediumBorder,
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SizedBox.square(
                dimension: 64,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    disabledBackgroundColor: AppColors.neutral200,
                    foregroundColor: AppColors.surface,
                    disabledForegroundColor: AppColors.neutral500,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    fixedSize: const Size.square(64),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: widget.sentence.isEmpty ? null : widget.onSpeak,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.volume_up_rounded, size: 28),
                        SizedBox(height: AppSpacing.xxs),
                        Text('Speak', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 2, height: 58, color: AppColors.neutral200),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Semantics(
                button: widget.sentence.isNotEmpty,
                enabled: widget.sentence.isNotEmpty,
                label: 'Speak selected words',
                child: GestureDetector(
                  key: const ValueKey<String>('sentence-word-area'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.sentence.isEmpty ? null : widget.onSpeak,
                  child:
                      widget.sentence.isEmpty
                          ? const _EmptySentencePrompt()
                          : Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: List<Widget>.generate(
                                  widget.sentence.length,
                                  (index) {
                                    final cell = widget.sentence[index];
                                    return Focus(
                                      autofocus:
                                          index == widget.sentence.length - 1,
                                      child: Chip(
                                        avatar: SizedBox.square(
                                          dimension: 28,
                                          child: CellVisual(
                                            cell: cell,
                                            fit: BoxFit.cover,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.medium,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        label: Text(
                                          cell.label,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        backgroundColor: cell.color.withValues(
                                          alpha: 0.20,
                                        ),
                                        side: BorderSide(
                                          color: cell.color,
                                          width: 2,
                                        ),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: AppRadius.mediumBorder,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _SentenceUndoButton(
                enabled: widget.sentence.isNotEmpty,
                onRemoveLast: widget.onRemoveLast,
                onClear: widget.onClear,
              ),
            ),
          ],
        ),
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
        Expanded(
          child: Text(
            'Choose words',
            style: TextStyle(
              color: AppColors.neutral700,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
