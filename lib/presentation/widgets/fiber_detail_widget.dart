import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../domain/models/dashboard/sugar_&_fiber_model.dart';
import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class FiberDetailWidget extends StatefulWidget {
  final SugarAndFiberModel? sugarAndFiberModel;
  const FiberDetailWidget({super.key, required this.sugarAndFiberModel});

  @override
  State<FiberDetailWidget> createState() =>
      _FiberDetailWidgetState();
}

class _FiberDetailWidgetState extends State<FiberDetailWidget> {
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
                  AppLocalizations.of(context)!.fiber,
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
              child: FillHorizontalBar(
                backgroundBarColor: AppColors.mountainMeadow,
                fractionToFill: widget.sugarAndFiberModel?.fractionToFillFiber ?? 0.0,
              ),
            ),
            SizedBox(height: Dimens.heightXXSmall,),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: Dimens.marginNormal),
              child: Text(
                widget.sugarAndFiberModel?.fractionToFillFiber.toString().appendGram() ?? '0.0 g',
                style: const TextStyle(
                  fontSize: Dimens.fontSizeSmall,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge, horizontal: Dimens.marginXLarge),
              child: Text(AppLocalizations.of(context)!.fiber_description),)
          ],
        ),
      ),
    );
  }
}
