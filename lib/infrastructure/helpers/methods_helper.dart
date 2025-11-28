import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

import '../utils/app_color.dart';

class MethodsHelper {


  static double getAverageInPercentage({double? consumed, double? total}) {
    double percent = consumed.orZero() / total.orZero();
    return percent * 100;
  }

  static LinearGradient getSugarLinearGradient({double? consumed, double? total}) {
    double percent = getAverageInPercentage(consumed: consumed, total: total);

    final Color mustard = Color(0xFFD1C413); // 0–5%
    final Color intenseRed = Color(0xFFF76C5E); // >10%
    // Gradient steps between 5–10%
    final List<Color> sugarGradientColors = [
      Color(0xFFD1C413), // Yellow
      Color(0xFFC9B30A), // Dark Yellow
      Color(0xFFE1A12A), // Light Orange
      Color(0xFFDA7A2A), // Dark Orange
      Color(0xFFF4735E), // Light Red
      Color(0xFFF76C5E), // Dark Red / Intense
    ];

    if (percent <= 100) {
      // Solid mustard
      return LinearGradient(
        colors: [mustard, mustard],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (percent > 100 && percent <= 200) {
      // Gradient proportional to percentage (5–10%)
      double gradientProgress = ((percent - 100) / 100).clamp(0.0, 1.0);

      // Interpolate between the gradient colors
      int colorCount = sugarGradientColors.length;
      int maxIndex = ((colorCount - 1) * gradientProgress).floor();
      Color endColor = sugarGradientColors[maxIndex];

      return LinearGradient(
        colors: [mustard, endColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // Percent > 10% → solid intense red
      return LinearGradient(
        colors: [intenseRed, intenseRed],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

}