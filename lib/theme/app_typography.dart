import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String headingFont = 'Poppins';
  static const String bodyFont = 'Inter';

  static const TextTheme textTheme = TextTheme(
    titleLarge: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(
      fontFamily: headingFont,
      fontWeight: FontWeight.w800,
    ),
    bodyLarge: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(fontFamily: bodyFont),
    labelLarge: TextStyle(fontFamily: headingFont, fontWeight: FontWeight.w700),
  );
}
