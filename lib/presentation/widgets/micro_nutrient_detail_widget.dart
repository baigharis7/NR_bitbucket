import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../infrastructure/utils/constants.dart';
import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class MicroNutrientDetailWidget extends StatefulWidget {
  final NutrientsModel nutrientsModel;
  final Color? titleColor;
  const MicroNutrientDetailWidget({super.key, required this.nutrientsModel, this.titleColor});

  @override
  State<MicroNutrientDetailWidget> createState() =>
      _MicroNutrientDetailWidgetState();
}

class _MicroNutrientDetailWidgetState extends State<MicroNutrientDetailWidget> {
  @override
  Widget build(BuildContext context) {
    final double percent = (widget.nutrientsModel.quantityConsumed / widget.nutrientsModel.rda);
    final double percentage = percent * 100;
    final color = widget.nutrientsModel.quantityConsumed > widget.nutrientsModel.upperLimit && widget.nutrientsModel.upperLimit > 0 ? AppColors.red : AppColors.green;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getNutrientName(widget.nutrientsModel.nutrientInfoMaster.translate(context)),
            style: TextStyle(
              color: widget.titleColor ?? AppColors.peacockBlue, fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall),
            child: Row(
              children: [
                Text(
                  '${(widget.nutrientsModel.quantityConsumed)} ${widget.nutrientsModel.unit}',
                  style: const TextStyle(color: Colors.black, fontSize: Dimens.fontSizeMedium, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${widget.nutrientsModel.rda} ${widget.nutrientsModel.unit}',
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          FillHorizontalBar(
            height: Dimens.heightXXSmall,
              // fillColor: widget.nutrientsModel.quantityConsumed > widget.nutrientsModel.upperLimit && widget.nutrientsModel.upperLimit > 0 ? AppColors.errorRed : AppColors.mountainMeadow,
              fillColor: color,
              fractionToFill: percent.clamp(0.0, 1.0),
              backgroundBarColor: Colors.transparent,),
          if (widget.nutrientsModel.nutrientInfoMaster.translateDescription(context).isNotEmptyOrNull()) Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal), child: Text(widget.nutrientsModel.nutrientInfoMaster.translateDescription(context))),
          if (widget.nutrientsModel.nutrientInfoMaster.foodSuggestion(context).isNotEmptyOrNull()) Text(widget.nutrientsModel.nutrientInfoMaster.foodSuggestion(context)),
        ],
      ),
    );
  }
}
