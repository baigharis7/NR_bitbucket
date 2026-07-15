import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class MacroNutrientDetailWidget extends StatefulWidget {
  final NutrientsModel nutrientsModel;
  final String description;
  const MacroNutrientDetailWidget({super.key, required this.nutrientsModel, required this.description});

  @override
  State<MacroNutrientDetailWidget> createState() =>
      _MacroNutrientDetailWidgetState();
}

class _MacroNutrientDetailWidgetState extends State<MacroNutrientDetailWidget> {
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
                          fillColor: widget.nutrientsModel.fractionToFill >= 1 ? AppColors.errorRed : AppColors.mountainMeadow,
                          fractionToFill: widget.nutrientsModel.fractionToFill,
                          backgroundBarColor: AppColors.mountainMeadow,
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                          child: Text(
                            '${widget.nutrientsModel.quantityConsumed.toNutrientDisplay()} ${widget.nutrientsModel.unit}',
                            style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
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
            if (widget.description.isNotEmpty) Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginXLarge),
              child: Text(widget.description),),
          ],
        ),
      ),
    );
  }
}
