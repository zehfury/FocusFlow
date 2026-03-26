import 'package:flutter/material.dart';

/// App-wide color tokens. Keep these stable; let ThemeData map them to UI.
sealed class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryContainer = Color(0xFF2A2155);

  static const Color background = Color(0xFF0E1016);
  static const Color surface = Color(0xFF151823);
  static const Color surfaceVariant = Color(0xFF1B2030);

  static const Color onBackground = Color(0xFFE7EAF3);
  static const Color onSurface = Color(0xFFE7EAF3);

  static const Color outline = Color(0xFF2E3346);
  static const Color danger = Color(0xFFFF4D6D);
  static const Color success = Color(0xFF2EE59D);
}

