import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../infrastructure/utils/app_color.dart';

class AnimatedNutrientProgressBarWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? title;
  final double percent;
  final Color? color;
  const AnimatedNutrientProgressBarWidget({super.key, this.height, this.width, this.title, required this.percent, this.color});

  @override
  Widget build(BuildContext context) {
    final progressWidth = width ?? MediaQuery.of(context).size.width;
    double progressFromPercent = progressWidth * (percent / 100);
    if (progressWidth < progressFromPercent) progressFromPercent = progressWidth;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall),
      child: Column(children: [
        Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.loose,
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: progressWidth,
              height: height ?? Dimens.height15,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(Dimens.border100)),
                color: AppColors.ceramic,
              ),
            ),
            TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progressFromPercent),
                duration: const Duration(seconds: 4),
                builder: (context, value, child) => Container(
                  width: value,
                  height: height ?? Dimens.height15,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(Dimens.border100)),
                    color: color ?? AppColors.mountainMeadow,
                  ),),
            ),
          ],
        ),
        if (title.isNotNull()) Container(
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall),
          child: Text(
            title ?? '',
            style: const TextStyle(fontSize: Dimens.fontSizeSmall, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis
          ),
        ),
      ],),
    );
  }

}