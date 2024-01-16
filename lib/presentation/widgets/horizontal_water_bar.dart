import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HorizontalWaterBar extends StatelessWidget {
  final double waterTaken;
  final double fractionToFill;
  final Function onAddWater;
  final double? cardElevation;

  const HorizontalWaterBar({
    Key? key,
    required this.waterTaken,
    required this.fractionToFill,
    required this.onAddWater,
    this.cardElevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      child: Card(
        elevation: cardElevation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(Dimens.marginLarge),
                child: Text(
                  '$waterTaken L',
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeLarge,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(top: Dimens.marginSmall),
                child: Column(
                  children: [
                    FillHorizontalBar(
                      fractionToFill: fractionToFill,
                      fillColor: Colors.blue,
                      applyBoxShadow: false,
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        AppLocalizations.of(context)!.water,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeSmall,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => onAddWater.call(),
                  icon: const Icon(
                    Icons.add_circle_outline_sharp,
                    color: Colors.blue,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}