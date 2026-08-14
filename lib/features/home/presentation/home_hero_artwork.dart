import 'package:flutter/material.dart';

/// Home hero decorative sports artwork (optional).
///
/// Drop a final transparent PNG/WebP at [assetPath] and set [enabled] to true.
/// Until then production renders without artwork; layout still reserves cleanly
/// when a provider is passed (e.g. visual-review Variant B).
abstract final class HomeHeroArtwork {
  static const String assetPath = 'assets/branding/home_hero_football.png';

  /// Display box for the decorative art (~20–30% of hero visual weight).
  static const double displaySize = 112;

  /// Recommended source asset: square transparent PNG, 512×512 (or 256×256).
  static const Size recommendedSourceSize = Size(512, 512);

  /// Aspect ratio of the reserved artwork slot.
  static const double aspectRatio = 1;

  /// Production gate — keep false until a final approved asset ships.
  static const bool enabled = false;

  static ImageProvider? get productionProvider =>
      enabled ? const AssetImage(assetPath) : null;
}
