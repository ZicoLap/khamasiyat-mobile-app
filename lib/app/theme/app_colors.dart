import 'package:flutter/material.dart';

/// Semantic brand colors for the customer app (light).
///
/// Use these tokens (or ColorScheme mapped from them) — avoid ad-hoc hex in widgets.
abstract final class AppColors {
  /// Rich stadium green — Home hero / brand surfaces (F2.3.1).
  /// Selected: #0D513D — warmer than near-black #052E22, not bright/teal.
  static const Color brandDeep = Color(0xFF0D513D);
  static const Color brandDeepLift = Color(0xFF11664C);
  static const Color brandDeepGlow = Color(0xFF147A58);

  /// Hero text on stadium green (warm whites / mint).
  static const Color heroOnBrand = Color(0xFFFFFBF7);
  static const Color heroOnBrandSoft = Color(0xFFD0E4D8);
  static const Color heroOnBrandMuted = Color(0xFFB4D0C2);

  /// Faint pitch-line texture on the hero (~5–8% opacity).
  static const Color heroPitchLine = Color(0x14FFFFFF);

  /// Fresh action green — CTAs, chips, selected states (distinct from brandDeep).
  static const Color primary = Color(0xFF0F9D58);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Soft green wash for chips / nav indicators.
  static const Color primarySoft = Color(0xFFD9F5E7);
  static const Color onPrimarySoft = Color(0xFF053D2A);

  /// Warm light canvas (not sterile dashboard gray).
  static const Color canvas = Color(0xFFF3F1EC);

  /// Elevated cards / sheets.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE8EBE7);

  static const Color onSurface = Color(0xFF121A16);
  static const Color onSurfaceMuted = Color(0xFF5B675F);

  static const Color outline = Color(0xFFC9D0CB);
  static const Color outlineSubtle = Color(0xFFE3E7E3);

  /// Image missing / loading wash (branded, quiet).
  static const Color imageFallback = Color(0xFF1A3D30);
  static const Color onImageFallback = Color(0xFFB7C9BF);

  /// Overlay scrim for discovery photo cards.
  static const Color imageScrim = Color(0xCC0D513D);

  /// Seed for Material ColorScheme generation.
  static const Color seed = primary;
}
