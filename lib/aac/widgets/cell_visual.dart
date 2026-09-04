import 'dart:io';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../models/aac_cell.dart';

class CellVisual extends StatelessWidget {
  const CellVisual({
    super.key,
    required this.cell,
    required this.fit,
    required this.borderRadius,
    required this.textStyle,
  });

  final AacCell cell;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    if (cell.hasPhoto) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(cell.photoPath!),
          fit: fit,
          cacheWidth: 300,
          cacheHeight: 300,
          alignment: Alignment.center,
          errorBuilder:
              (_, __, ___) => const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.neutral500,
                ),
              ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Text(cell.symbol, textAlign: TextAlign.center, style: textStyle),
    );
  }
}
