import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class BoardToolbar extends StatelessWidget {
  const BoardToolbar({
    super.key,
    required this.depth,
    required this.editMode,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onEditModeChanged,
    this.onReset,
  });

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
                      const Expanded(child: _ToolbarIdentity(showLabel: true)),
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
                      const _ToolbarIdentity(showLabel: false),
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
  const _ToolbarIdentity({required this.showLabel});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: AppRadius.mediumBorder,
          child: Image.asset(
            'assets/images/speech-relay-by-topitot-logo-1000x1000.png',
            key: const ValueKey<String>('toolbar-app-icon'),
            width: 36,
            height: 36,
            cacheWidth: 108,
            cacheHeight: 108,
            fit: BoxFit.cover,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Speech Relay',
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
