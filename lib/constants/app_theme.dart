import 'package:flutter/material.dart';

class AppTheme {
  // iOS-style spacing constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Colors
  static const Color primaryColor = Color(0xFF007AFF); // iOS blue
  static const Color destructiveColor = Color(0xFFFF3B30); // iOS red
  static const Color successColor = Color(0xFF34C759); // iOS green
  static const Color warningColor = Color(0xFFFF9500); // iOS orange

  static const Color backgroundColor = Color(0xFFF2F2F7); // iOS background
  static const Color cardBackground = Colors.white;
  static const Color shadowColor = Color(0x0A000000);

  // iOS-style text styles
  static const TextStyle largeTitleStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.37,
  );

  static const TextStyle title1Style = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.36,
  );

  static const TextStyle title2Style = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.35,
  );

  static const TextStyle title3Style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
  );

  static const TextStyle calloutStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.32,
  );

  static const TextStyle subheadStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
  );

  static const TextStyle footnoteStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
  );

  static const TextStyle caption1Style = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  static const TextStyle caption2Style = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.06,
  );

  // Shadow styles
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: shadowColor,
          offset: Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => const [
        BoxShadow(
          color: Color(0x1A000000),
          offset: Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
}
