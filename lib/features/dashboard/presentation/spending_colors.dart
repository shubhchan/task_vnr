import 'package:flutter/material.dart';

import '../../tasks/domain/task.dart';

/// Shared category colours so the chart, legend, and detail screen match.
class SpendingColors {
  const SpendingColors._();

  static const byCategory = {
    TaskCategory.work: Color(0xFF4F6BED),
    TaskCategory.personal: Color(0xFF26A69A),
    TaskCategory.travel: Color(0xFFF59E0B),
    TaskCategory.food: Color(0xFFEC4899),
  };

  static Color of(TaskCategory category) => byCategory[category] ?? Colors.grey;

  static Color on(TaskCategory category) {
    final brightness = ThemeData.estimateBrightnessForColor(of(category));
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
}
