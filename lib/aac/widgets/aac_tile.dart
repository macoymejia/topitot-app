import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../models/aac_cell.dart';
import 'cell_visual.dart';

class AacTile extends StatelessWidget {
  const AacTile({
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
                                      width: symbolBoxHeight,
                                      child: CellVisual(
                                        cell: cell,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.large,
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w900,
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
