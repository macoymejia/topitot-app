import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../models/aac_cell.dart';
import 'cell_visual.dart';

class SentenceStrip extends StatelessWidget {
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
            child: Semantics(
              button: sentence.isNotEmpty,
              enabled: sentence.isNotEmpty,
              label: 'Speak selected words',
              child: GestureDetector(
                key: const ValueKey<String>('sentence-word-area'),
                behavior: HitTestBehavior.opaque,
                onTap: sentence.isEmpty ? null : onSpeak,
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
                              avatar: SizedBox.square(
                                dimension: 28,
                                child: CellVisual(
                                  cell: cell,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                  textStyle: const TextStyle(fontSize: 20),
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
                              side: BorderSide(color: cell.color, width: 2),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.mediumBorder,
                              ),
                            );
                          },
                        ),
              ),
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
        Expanded(
          child: Text(
            'Choose words',
            style: TextStyle(
              color: AppColors.neutral700,
              fontSize: 24,
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
