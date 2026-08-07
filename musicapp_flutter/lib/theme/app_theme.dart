import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

/// Builds the light/dark ThemeData for the app. Typography mirrors the web
/// app: Fraunces (a warm serif) for display/headings, Inter for body text.
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color textColor, Color mutedColor) {
    final base = GoogleFonts.interTextTheme();
    final display = GoogleFonts.frauncesTextTheme();

    return base.copyWith(
      displayLarge: display.displayLarge?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      displayMedium: display.displayMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      displaySmall: display.displaySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      headlineLarge: display.headlineLarge?.copyWith(color: textColor, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineMedium: display.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600, letterSpacing: -0.4),
      headlineSmall: display.headlineSmall?.copyWith(color: textColor, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleLarge: base.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: textColor),
      bodyMedium: base.bodyMedium?.copyWith(color: textColor),
      bodySmall: base.bodySmall?.copyWith(color: mutedColor),
      labelLarge: base.labelLarge?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: mutedColor, fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(color: mutedColor, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get light {
    const ext = AppThemeExtension.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ext.bg0,
      canvasColor: ext.bg0,
      colorScheme: ColorScheme.light(
        primary: ext.accent,
        onPrimary: ext.accentContrast,
        secondary: ext.accent,
        surface: ext.surface,
        onSurface: ext.text0,
        error: ext.danger,
      ),
      textTheme: _textTheme(ext.text0, ext.text1),
      dividerColor: ext.borderColor,
      splashColor: ext.accent.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      extensions: const [ext],
    );
  }

  static ThemeData get dark {
    const ext = AppThemeExtension.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ext.bg0,
      canvasColor: ext.bg0,
      colorScheme: ColorScheme.dark(
        primary: ext.accent,
        onPrimary: ext.accentContrast,
        secondary: ext.accent,
        surface: ext.surface,
        onSurface: ext.text0,
        error: ext.danger,
      ),
      textTheme: _textTheme(ext.text0, ext.text1),
      dividerColor: ext.borderColor,
      splashColor: ext.accent.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      extensions: const [ext],
    );
  }
}

/// Radii, kept as plain constants for convenience (mirrors --r-* tokens).
class AppRadius {
  AppRadius._();
  static const sm = AppColors.radiusSm;
  static const md = AppColors.radiusMd;
  static const lg = AppColors.radiusLg;
  static const xl = AppColors.radiusXl;
  static const pill = AppColors.radiusPill;
}
