import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../constants/aac_constants.dart';
import '../models/aac_cell.dart';
import 'aac_tile.dart';

class AacGrid extends StatelessWidget {
  const AacGrid({
    super.key,
    required this.cells,
    required this.editMode,
    required this.canGoBack,
    required this.onBack,
    required this.onHome,
    required this.onCellTap,
  });

  final List<AacCell> cells;
  final bool editMode;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback? onHome;
  final ValueChanged<AacCell> onCellTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.gridGap;
        final gridWidth = constraints.maxWidth;
        final gridHeight = constraints.maxHeight;
        final tileWidth =
            (gridWidth - (boardColumns - 1) * spacing) / boardColumns;
        final tileHeight = (gridHeight - (boardRows - 1) * spacing) / boardRows;
        final uncappedAspectRatio =
            tileHeight <= 0 ? 1.0 : tileWidth / tileHeight;
        final aspectRatio =
            uncappedAspectRatio < 0.72 ? 0.72 : uncappedAspectRatio;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardColumns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: cellsPerPage,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _GridNavigationTile(
                key: const ValueKey<String>('grid-back-cell'),
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                enabled: canGoBack,
                onTap: onBack,
              );
            }
            if (index == 1) {
              return _GridNavigationTile(
                key: const ValueKey<String>('grid-home-cell'),
                label: 'Home',
                icon: Icons.home_rounded,
                enabled: onHome != null,
                onTap: onHome,
              );
            }

            final cell = cells[index - 2];
            return AacTile(
              key: ValueKey<String>('aac-cell-$index'),
              cell: cell,
              editMode: editMode,
              onTap: () => onCellTap(cell),
            );
          },
        );
      },
    );
  }
}

class _GridNavigationTile extends StatelessWidget {
  const _GridNavigationTile({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? AppColors.neutral700 : AppColors.neutral500;
    final background =
        enabled ? AppColors.selectedSurface : AppColors.disabledSurface;
    final border = enabled ? AppColors.primary : AppColors.neutral200;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: background,
        borderRadius: AppRadius.mediumBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 3),
              borderRadius: AppRadius.mediumBorder,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 112;
                final ultraCompact =
                    constraints.maxHeight < 56 || constraints.maxWidth < 72;
                final iconSize =
                    constraints.maxHeight * (compact ? 0.34 : 0.38);
                final labelSize =
                    constraints.maxHeight * (compact ? 0.14 : 0.16);

                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      compact ? AppSpacing.xs : AppSpacing.sm,
                    ),
                    child:
                        ultraCompact
                            ? Icon(
                              icon,
                              color: foreground,
                              size: iconSize.clamp(18, 30),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  icon,
                                  color: foreground,
                                  size: iconSize.clamp(24, 54),
                                ),
                                SizedBox(
                                  height:
                                      compact ? AppSpacing.xxs : AppSpacing.xs,
                                ),
                                Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: labelSize.clamp(11, 20),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
