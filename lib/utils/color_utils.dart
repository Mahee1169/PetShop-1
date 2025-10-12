import 'package:flutter/material.dart';

/// Helper extension to handle color opacity in a non-deprecated way
extension ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withOpacity(opacity);
  }
}