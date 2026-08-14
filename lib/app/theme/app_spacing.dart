import 'package:flutter/material.dart';

/// Spacing scale (logical pixels).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(sm);
}
