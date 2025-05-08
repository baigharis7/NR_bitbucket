import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class MicroNutrientDetailWidget extends StatefulWidget {
  final NutrientsModel nutrientsModel;
  const MicroNutrientDetailWidget({super.key, required this.nutrientsModel});

  @override
  State<MicroNutrientDetailWidget> createState() =>
      _MicroNutrientDetailWidgetState();
}

class _MicroNutrientDetailWidgetState extends State<MicroNutrientDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginSmall),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                      left: Dimens.marginNormal,
                      top: Dimens.marginSmall,
                    ),
                    child: SizedBox(
                      child: Text(
                        getNutrientName(widget.nutrientsModel.nutrientInfoMaster.translate(context)),
                        style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.only(
                      right: Dimens.marginLarge,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        FillHorizontalBar(
                            fillColor: widget.nutrientsModel.fractionToFill >= 1 && widget.nutrientsModel.upperLimit > 0 ? AppColors.errorRed : AppColors.mountainMeadow,
                            fractionToFill: widget.nutrientsModel.fractionToFill,
                        backgroundBarColor: AppColors.cardGreen_200),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                          child: Text(
                            '${(widget.nutrientsModel.quantityConsumed)} ${widget.nutrientsModel.unit}',
                            style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: Dimens.marginNormal),
              child: Text(
                '${widget.nutrientsModel.rda} ${widget.nutrientsModel.unit}',
                style: const TextStyle(
                  fontSize: Dimens.fontSizeSmall,
                ),
              ),
            ),
            if (widget.nutrientsModel.nutrientInfoMaster.translateDescription(context).isNotEmptyOrNull()) Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginXLarge),
              child: Text(widget.nutrientsModel.nutrientInfoMaster.translateDescription(context)),),
            if (widget.nutrientsModel.nutrientInfoMaster.foodSuggestion(context).isNotEmptyOrNull()) Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall, horizontal: Dimens.marginXLarge),
              child: Text(widget.nutrientsModel.nutrientInfoMaster.foodSuggestion(context)),),
          ],
        ),
      ),
    );
  }
}
