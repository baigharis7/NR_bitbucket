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
    final linearGradient = LinearGradient(colors: (percent > Constants.PERCENTAGE_50 && percent <= Constants.PERCENTAGE_100) ? [AppColors.mustardYellow, AppColors.red] : (percent > Constants.PERCENTAGE_100) ? [AppColors.red, AppColors.red] : [AppColors.mustardYellow, AppColors.mustardYellow], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.8,]);
    return linearGradient;
  }

}