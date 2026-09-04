import 'package:flutter/material.dart';

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
    required this.onHome,
    required this.onCellTap,
  });

  final List<AacCell> cells;
  final bool editMode;
  final bool canGoBack;
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
            final cell = cells[index];
            final enabled =
                cell.label == 'Back'
                    ? canGoBack
                    : cell.label == 'Home'
                    ? onHome != null
                    : true;
            return AacTile(
              key: ValueKey<String>('aac-cell-$index'),
              cell: cell,
              editMode: editMode,
              enabled: enabled,
              onTap: enabled ? () => onCellTap(cell) : null,
            );
          },
        );
      },
    );
  }
}
