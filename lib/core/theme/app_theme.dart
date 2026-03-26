import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

sealed class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onSurface,
      secondary: const Color(0xFF4CD4FF),
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF0D2B36),
      onSecondaryContainer: AppColors.onSurface,
      tertiary: const Color(0xFFFFD166),
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFF3D2F0C),
      onTertiaryContainer: AppColors.onSurface,
      error: AppColors.danger,
      onError: Colors.black,
      errorContainer: const Color(0xFF3B0B18),
      onErrorContainer: AppColors.onSurface,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: const Color(0xFFC8CDE0),
      outline: AppColors.outline,
      outlineVariant: const Color(0xFF24283A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE7EAF3),
      onInverseSurface: const Color(0xFF0E1016),
      inversePrimary: const Color(0xFF4B33C9),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    final shape = RoundedRectangleBorder(borderRadius: AppRadii.card);

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.label.copyWith(color: AppColors.onSurface),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: shape,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceVariant,
        shape: shape,
        contentTextStyle:
            base.textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme scheme) {
    return base.copyWith(
      displaySmall: AppTextStyles.display.copyWith(color: scheme.onSurface),
      titleLarge: AppTextStyles.title.copyWith(color: scheme.onSurface),
      bodyLarge: AppTextStyles.body.copyWith(color: scheme.onSurface),
      bodyMedium: AppTextStyles.body.copyWith(color: scheme.onSurface),
      labelLarge: AppTextStyles.label.copyWith(color: scheme.onSurface),
    );
  }
}

