import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
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
    final fillRatio = widget.nutrient.rda > 0 ? (widget.nutrient.quantityConsumed / widget.nutrient.rda).clamp(0.0, 1.0) : 0.0;
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
            child: Tooltip(
              onTriggered: () {
                setState(() {
                  selectedNutrient = getNutrientName(widget.nutrient.nutrientInfoMaster.translate(context)).toUpperCase();
                  selectedValue = widget.nutrient.quantityConsumed;
                });
              },
              message: '$selectedNutrient: ${selectedValue?.toStringAsFixed(1)} ${widget.nutrient.unit}',
              preferBelow: false,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 31,
                    height: 84,
                    margin: const EdgeInsets.symmetric(vertical: Dimens.margin6),
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: AppColors.black,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Fill bar
                        Container(
                          width: 30,
                          height: fillRatio * 84,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors, begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        // Value label inside the bar
                        if (fillRatio > 0.15)
                          Positioned(
                            bottom: (fillRatio * 84) / 2 - 8,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.nutrient.quantityConsumed >= 10
                                        ? '${widget.nutrient.quantityConsumed.toInt()}'
                                        : widget.nutrient.quantityConsumed.toStringAsFixed(1),
                                    style: AppTextStyles.dmSans.copyWith(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: widget.nutrient.unit.orEmpty(),
                                    style: AppTextStyles.dmSans.copyWith(fontWeight: FontWeight.w700, fontSize: 6, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(widget.nutrient.nutrientInfoMaster.abbr.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: widget.titleColor ?? AppColors.peacockBlue,)),
        ],
      ),
    );
  }
}
