import 'package:flutter/material.dart';
extension ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    final int alpha = (opacity * 255).round();
    final int clamped = alpha < 0 ? 0 : (alpha > 255 ? 255 : alpha);
    return withAlpha(clamped);
  }
}