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
    this.enabled = true,
    this.onTap,
  });

  final AacCell cell;
  final bool editMode;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && (editMode || !cell.isBlank);
    final isEmptyCell = cell.isBlank && !editMode;
    final foreground =
        cell.color.computeLuminance() > 0.45
            ? AppColors.neutral900
            : AppColors.surface;
    final tileColor = isEmptyCell ? AppColors.transparent : cell.color;
    final borderColor =
        isEmptyCell
            ? AppColors.transparent
            : !enabled
            ? AppColors.neutral200
            : editMode
            ? AppColors.neutral900
            : cell.isFolder
            ? AppColors.primary
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
        color: enabled ? tileColor : AppColors.disabledSurface,
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
                width: isEmptyCell ? 0 : (editMode || cell.isFolder ? 4 : 0),
              ),
              borderRadius: AppRadius.mediumBorder,
            ),
            child: Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (isEmptyCell) {
                      return const SizedBox.expand();
                    }

                    final compact = constraints.maxHeight < 112;
                    final shortestSide =
                        constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                    final symbolBoxHeight =
                        shortestSide * (compact ? 0.72 : 0.80);
                    final labelSize = compact ? 8.5 : 20.0;

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 2 : AppSpacing.sm,
                          compact ? 2 : AppSpacing.sm,
                          compact ? 2 : AppSpacing.sm,
                          compact ? 2 : AppSpacing.sm,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: symbolBoxHeight,
                              width: symbolBoxHeight,
                              child:
                                  cell.label == 'Back'
                                      ? Icon(
                                        Icons.arrow_back_rounded,
                                        color: foreground,
                                        size: symbolBoxHeight * 0.95,
                                      )
                                      : cell.label == 'Home'
                                      ? Icon(
                                        Icons.home_rounded,
                                        color: foreground,
                                        size: symbolBoxHeight * 0.95,
                                      )
                                      : CellVisual(
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
                            if (cell.label != 'Back' &&
                                cell.label != 'Home') ...[
                              if (!compact)
                                const SizedBox(height: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  cell.label,
                                  maxLines: compact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        !enabled
                                            ? AppColors.neutral500
                                            : cell.isBlank
                                            ? AppColors.neutral500
                                            : foreground,
                                    fontSize: labelSize.clamp(13, 20),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
                      width: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.medium),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 28,
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
