import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../constants/aac_constants.dart';

class BoardToolbar extends StatelessWidget {
  const BoardToolbar({
    super.key,
    required this.title,
    required this.depth,
    required this.editMode,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onEditModeChanged,
    this.onReset,
  });

  final String title;
  final int depth;
  final bool editMode;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<bool> onEditModeChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    const toolbarHeight = 60.0;
    const toolbarPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    );

    return SizedBox(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactActions = constraints.maxWidth < 400;

              return expanded
                  ? Row(
                    children: <Widget>[
                      Expanded(child: _ToolbarIdentity(title: title)),
                      SizedBox(
                        width: compactActions ? AppSpacing.sm : AppSpacing.lg,
                      ),
                      if (onReset != null) ...[
                        if (compactActions)
                          SizedBox.square(
                            dimension: 48,
                            child: IconButton.outlined(
                              tooltip: 'Reset',
                              onPressed: onReset,
                              color: AppColors.accent,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: onReset,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reset'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: const BorderSide(color: AppColors.accent),
                            ),
                          ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Tooltip(
                        message:
                            editMode
                                ? 'Return to use mode'
                                : 'Switch to edit mode',
                        child: FilledButton.tonalIcon(
                          onPressed: () => onEditModeChanged(!editMode),
                          icon: Icon(
                            editMode ? Icons.check_rounded : Icons.edit_rounded,
                          ),
                          label: Text(
                            editMode
                                ? compactActions
                                    ? 'Done'
                                    : 'Done Editing'
                                : compactActions
                                ? 'Edit'
                                : 'Edit Board',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      SizedBox.square(
                        dimension: 48,
                        child: IconButton.filledTonal(
                          tooltip: 'Collapse toolbar',
                          onPressed: () => onExpandedChanged(false),
                          icon: const Icon(Icons.expand_less_rounded),
                        ),
                      ),
                    ],
                  )
                  : Row(
                    children: <Widget>[
                      Expanded(child: _ToolbarIdentity(title: title)),
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
                  );
            },
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
    return Row(
      mainAxisSize: MainAxisSize.min,
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
