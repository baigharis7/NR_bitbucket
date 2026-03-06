import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../domain/models/dashboard/sugar_&_fiber_model.dart';
import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class SugarDetailWidget extends StatefulWidget {
  final SugarAndFiberModel? sugarAndFiberModel;
  SugarDetailWidget({required this.sugarAndFiberModel});

  @override
  State<SugarDetailWidget> createState() =>
      _SugarDetailWidgetState();
}

class _SugarDetailWidgetState extends State<SugarDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginSmall),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                left: Dimens.marginNormal,
                top: Dimens.marginSmall,
              ),
              child: SizedBox(
                child: Text(
                  AppLocalizations.of(context)!.sugar,
                  style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimens.marginLarge,
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FillHorizontalBar(
                    backgroundBarColor: AppColors.mountainMeadow,
                    fractionToFill: widget.sugarAndFiberModel?.fractionToFillSugar ?? 0.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                    child: Text(
                      '${widget.sugarAndFiberModel?.totalSugarConsumed ?? 0.0}',
                      style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimens.heightXXSmall,),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: Dimens.marginNormal),
              child: Text(
                widget.sugarAndFiberModel?.requiredSugar.toString().appendGram() ?? '0.0 g',
                style: const TextStyle(
                  fontSize: Dimens.fontSizeSmall,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginXLarge),
              child: Text(AppLocalizations.of(context)!.sugar_description),)
          ],
        ),
      ),
    );
  }
}
