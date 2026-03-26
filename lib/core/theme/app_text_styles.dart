import 'package:flutter/material.dart';

/// Type scale for the app.
///
/// Prefer using Theme.of(context).textTheme in widgets. These styles are used
/// to build the theme and as reference tokens.
sealed class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto';

  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

