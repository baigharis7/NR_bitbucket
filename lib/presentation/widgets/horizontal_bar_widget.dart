import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class HorizontalBarWidget extends StatelessWidget {
  final BoxShape? boxShape;
  final double? radius;
  final Color? barColor;
  final Color? barBackgroundColor;
  final double? barHeight;
  final double fillBarValue;

  const HorizontalBarWidget({
    super.key,
    this.boxShape,
    this.radius,
    this.barColor,
    this.barBackgroundColor,
    this.barHeight,
    required this.fillBarValue,
  });

  @override
  Widget build(BuildContext context) {
    var fillingValue = fillBarValue > 1 ? 1 : fillBarValue;
    return Container(
      decoration: BoxDecoration(
        color: barBackgroundColor ?? Colors.grey[350],
        borderRadius: BorderRadius.circular(
          radius ?? 10,
        ),
        shape: BoxShape.rectangle,
      ),
      width: double.infinity,
      height: barHeight ?? Dimens.height30,
      child: FractionallySizedBox(
        alignment: FractionalOffset.centerLeft,
        widthFactor: fillingValue.toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: fillingValue >= 1 ? AppColors.errorRed : AppColors.mountainMeadow,
            borderRadius: BorderRadius.circular(
              radius ?? 10,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
    );
  }
}
