import 'package:flutter/material.dart';

/// Helper extension to handle color opacity in a non-deprecated way
extension ColorExtension on Color {
  /// Returns this color with the given opacity (0.0 - 1.0) without using
  /// the deprecated `withOpacity` API. Converts the opacity to an 0-255
  /// alpha value and calls `withAlpha` which is stable.
  Color withOpacityValue(double opacity) {
    final int alpha = (opacity * 255).round();
    final int clamped = alpha < 0 ? 0 : (alpha > 255 ? 255 : alpha);
    return withAlpha(clamped);
  }
}