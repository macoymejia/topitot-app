import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFFFBBF24);
  static const Color accent = Color(0xFFFF7A59);
  static const Color success = Color(0xFF22C55E);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral200 = Color(0xFFE2E8F0);

  static const Color blueSoft = Color(0xFF60A5FA);
  static const Color greenSoft = Color(0xFF86EFAC);
  static const Color yellowSoft = Color(0xFFFDE68A);
  static const Color coralSoft = Color(0xFFFFA385);
  static const Color lavender = Color(0xFFC084FC);
  static const Color slateSoft = Color(0xFFCBD5E1);
  static const Color pinkSoft = Color(0xFFF9A8D4);
  static const Color limeSoft = Color(0xFFBEF264);

  static const Color editSurface = Color(0xFFFFF7D6);
  static const Color disabledSurface = Color(0xFFF1F5F9);
  static const Color selectedSurface = Color(0xFFEFF6FF);
  static const Color emptyCell = Color(0xFFE8EDF3);
  static const Color shadow = Color(0x1F0F172A);
  static const Color transparent = Colors.transparent;

  static const int emptyCellArgb = 0xFFE8EDF3;

  static const List<Color> cellSwatches = <Color>[
    blueSoft,
    greenSoft,
    yellowSoft,
    coralSoft,
    lavender,
    slateSoft,
    pinkSoft,
    limeSoft,
  ];
}
