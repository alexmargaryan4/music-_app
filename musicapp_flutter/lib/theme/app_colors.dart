import 'package:flutter/material.dart';

/// Color tokens ported 1:1 from the web app's `variables.css`: a neutral,
/// near-monochrome gray scale (no hue tint) with a pure black/white "ink"
/// accent. Frosted-glass panels float on a plain neutral canvas.
class AppColors {
  AppColors._();

  // ---- Light theme ----
  static const bg0Light = Color(0xFFF5F5F6); // 220 10% 97%
  static const bg1Light = Color(0xFFEBEDEF); // 220 12% 93%
  static const surfaceLight = Color(0xFFFFFFFF);
  static const text0Light = Color(0xFF1C1E22); // 220 12% 12%
  static const text1Light = Color(0xFF595C63); // 220 8% 38%
  static const text2Light = Color(0xFF868A91); // 220 6% 55%
  static const borderLight = Color(0xFFD3D6DB); // 220 10% 85%

  // ---- Dark theme ----
  static const bg0Dark = Color(0xFF101216); // 220 16% 7%
  static const bg1Dark = Color(0xFF181B20); // 220 14% 11%
  static const surfaceDark = Color(0xFF1D2025); // 220 14% 13%
  static const text0Dark = Color(0xFFF3F4F5); // 220 10% 96%
  static const text1Dark = Color(0xFFC5C8CC); // 220 8% 78%
  static const text2Dark = Color(0xFF8E9298); // 220 6% 58%
  static const borderDark = Color(0xFF373C44); // 220 12% 24%

  // ---- Monochrome "ink" accent ----
  static const accent500Light = Color(0xFF17191D); // near-black ink
  static const accent600Light = Color(0xFF08090B);
  static const accentContrastLight = Color(0xFFFFFFFF);

  static const accent500Dark = Color(0xFFF3F4F6); // near-white ink
  static const accent600Dark = Color(0xFFFFFFFF);
  static const accentContrastDark = Color(0xFF14161A);

  static const success = Color(0xFF3F9A6E); // 152 40% 42%
  static const danger = Color(0xFFD1495B); // 355 55% 56%

  // ---- Radii ----
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;
  static const double radiusPill = 999;
}
