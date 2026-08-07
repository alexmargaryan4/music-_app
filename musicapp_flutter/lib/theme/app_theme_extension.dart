import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic tokens that change between light/dark but aren't part of
/// Flutter's built-in ColorScheme — mirrors the extra custom properties
/// in the web app's variables.css (bg1, text2, glass tint/alpha, accent).
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color bg0;
  final Color bg1;
  final Color surface;
  final Color text0;
  final Color text1;
  final Color text2;
  final Color borderColor;
  final Color glassTint;
  final double glassAlpha;
  final double glassAlphaStrong;
  final Color accent;
  final Color accentStrong;
  final Color accentContrast;
  final Color success;
  final Color danger;

  const AppThemeExtension({
    required this.bg0,
    required this.bg1,
    required this.surface,
    required this.text0,
    required this.text1,
    required this.text2,
    required this.borderColor,
    required this.glassTint,
    required this.glassAlpha,
    required this.glassAlphaStrong,
    required this.accent,
    required this.accentStrong,
    required this.accentContrast,
    required this.success,
    required this.danger,
  });

  static const light = AppThemeExtension(
    bg0: AppColors.bg0Light,
    bg1: AppColors.bg1Light,
    surface: AppColors.surfaceLight,
    text0: AppColors.text0Light,
    text1: AppColors.text1Light,
    text2: AppColors.text2Light,
    borderColor: AppColors.borderLight,
    glassTint: Colors.white,
    glassAlpha: 0.55,
    glassAlphaStrong: 0.75,
    accent: AppColors.accent500Light,
    accentStrong: AppColors.accent600Light,
    accentContrast: AppColors.accentContrastLight,
    success: AppColors.success,
    danger: AppColors.danger,
  );

  static const dark = AppThemeExtension(
    bg0: AppColors.bg0Dark,
    bg1: AppColors.bg1Dark,
    surface: AppColors.surfaceDark,
    text0: AppColors.text0Dark,
    text1: AppColors.text1Dark,
    text2: AppColors.text2Dark,
    borderColor: AppColors.borderDark,
    glassTint: const Color(0xFF23262C),
    glassAlpha: 0.55,
    glassAlphaStrong: 0.78,
    accent: AppColors.accent500Dark,
    accentStrong: AppColors.accent600Dark,
    accentContrast: AppColors.accentContrastDark,
    success: AppColors.success,
    danger: AppColors.danger,
  );

  @override
  AppThemeExtension copyWith({
    Color? bg0,
    Color? bg1,
    Color? surface,
    Color? text0,
    Color? text1,
    Color? text2,
    Color? borderColor,
    Color? glassTint,
    double? glassAlpha,
    double? glassAlphaStrong,
    Color? accent,
    Color? accentStrong,
    Color? accentContrast,
    Color? success,
    Color? danger,
  }) {
    return AppThemeExtension(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      surface: surface ?? this.surface,
      text0: text0 ?? this.text0,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      borderColor: borderColor ?? this.borderColor,
      glassTint: glassTint ?? this.glassTint,
      glassAlpha: glassAlpha ?? this.glassAlpha,
      glassAlphaStrong: glassAlphaStrong ?? this.glassAlphaStrong,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentContrast: accentContrast ?? this.accentContrast,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text0: Color.lerp(text0, other.text0, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      glassAlpha: (glassAlpha + (other.glassAlpha - glassAlpha) * t),
      glassAlphaStrong: (glassAlphaStrong + (other.glassAlphaStrong - glassAlphaStrong) * t),
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentContrast: Color.lerp(accentContrast, other.accentContrast, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get colors => Theme.of(this).extension<AppThemeExtension>()!;
}
