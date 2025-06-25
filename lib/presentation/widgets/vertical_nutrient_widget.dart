import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/string_utils.dart';

class VerticalNutrientWidget extends StatefulWidget {
  final NutrientsModel nutrient;
  final Color? titleColor;
  const VerticalNutrientWidget({super.key, required this.nutrient, this.titleColor});

  @override
  State<VerticalNutrientWidget> createState() => _VerticalNutrientWidgetState();
}

class _VerticalNutrientWidgetState extends State<VerticalNutrientWidget> {
  String? selectedNutrient;
  double? selectedValue;
  Offset? infoOffset;

  @override
  Widget build(BuildContext context) {
    final colors = widget.nutrient.quantityConsumed > widget.nutrient.upperLimit && widget.nutrient.upperLimit > 0 ? [AppColors.rose, AppColors.persianRed] : [AppColors.lightGreen, AppColors.green];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
      height: Dimens.heightMedium,
      width: Dimens.width60,
      child: Column(
        children: [
          Text('${widget.nutrient.rda} ${widget.nutrient.unit}', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: widget.titleColor ?? AppColors.peacockBlue, fontSize: Dimens.fontSizeXSmall, fontWeight: FontWeight.w600)),
          GestureDetector(
            onLongPressStart: (details) {
              setState(() {
                selectedNutrient = getNutrientName(widget.nutrient.nutrientInfoMaster.translate(context)).toUpperCase();
                selectedValue = widget.nutrient.quantityConsumed;
                infoOffset = details.globalPosition;
              });
            },
            onLongPressEnd: (_) {
              setState(() {
                selectedNutrient = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.margin6),
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Container(
                        width: 31,
                        height: 84,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors.black,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.nutrient.quantityConsumed),
                        duration: const Duration(seconds: 5),
                        builder: (context, value, child) {
                          return Container(
                            width: 31,
                            height: (widget.nutrient.quantityConsumed / widget.nutrient.rda) * 84,
                            // alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors, begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                              // gradient: LinearGradient(colors: [AppColors.algaeGreen, AppColors.mediumGreen], begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                              // gradient: LinearGradient(colors: [AppColors.rose, AppColors.persianRed], begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                              // color: AppColors.peacockBlue,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (selectedNutrient != null && infoOffset != null)
                    Positioned(
                      top: Dimens.zero,
                      child: Container(
                        padding: const EdgeInsets.all(Dimens.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$selectedNutrient: ${selectedValue!.toStringAsFixed(1)} ${widget.nutrient.unit}',
                          style: const TextStyle(color: Colors.white,),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(widget.nutrient.nutrientInfoMaster.abbr.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: widget.titleColor ?? AppColors.peacockBlue, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationThickness: 2,)),
        ],
      ),
    );
  }
}