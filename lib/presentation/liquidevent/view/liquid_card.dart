import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class LiquidCard extends StatelessWidget {
  final String liquidName;
  final String quantity;
  final Function removeLiquid;
  final Function editLiquid;

  const LiquidCard({
    Key? key,
    required this.liquidName,
    required this.quantity,
    required this.removeLiquid,
    required this.editLiquid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only(
          left: Dimens.marginNormal,
          right: Dimens.marginNormal,
          bottom: Dimens.marginNormal,
        ),
        child: Card(
          color: Colors.green[200],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: Dimens.marginNormal,
                    ),
                    child: Text(
                      liquidName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => removeLiquid.call(),
                    icon: const Icon(Icons.clear),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: Dimens.marginNormal,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(AppLocalizations.of(context)!.quantity),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(quantity),
                    ),
                    Expanded(child: Text(/*foodInEvent.unit*/AppLocalizations.of(context)!.ml.toLowerCase()))
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => editLiquid.call(),
                  icon: const Icon(Icons.edit),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}