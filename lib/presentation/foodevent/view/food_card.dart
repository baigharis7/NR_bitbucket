import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/oil_types_response.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class FoodCard extends StatelessWidget {
  final String foodName;
  final String cookingMethod;
  final String quantity;
  final String unit;
  final ConversionFactor? conversionFactor;
  final OilTypeResponse? usedOil;
  final Function? removeFood;
  final Function? editFood;

  const FoodCard({
    Key? key,
    required this.foodName,
    required this.cookingMethod,
    required this.quantity,
    required this.unit,
    this.conversionFactor,
    this.usedOil,
    this.removeFood,
    this.editFood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only(left: Dimens.marginNormal, bottom: Dimens.marginNormal, right: Dimens.marginNormal),
        child: Column(
          children: [
            Card(
              color: int.parse(quantity) < 0 ? Colors.amber.shade100 : Colors.green[200],
              child: Container(decoration: BoxDecoration(border: Border.all(color: int.parse(quantity) < 0 ? Colors.red : int.parse(quantity) < 0 ? Colors.amber.shade100 : Colors.green.shade200, width: 2),borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: Dimens.marginNormal,
                          top: Dimens.marginNormal,
                          bottom: Dimens.marginNormal,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              foodName,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!removeFood.isNull()) Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () => removeFood?.call(),
                              icon: const Icon(Icons.clear),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal, bottom: Dimens.marginNormal),
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
                          // TODO: Buscar la unidad en la tabla maestra de unidades.
                          Expanded(child: Text(unit))
                        ],
                      ),
                    ),
                    if (!conversionFactor.isNull()) Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal, bottom: Dimens.marginNormal),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(AppLocalizations.of(context)!.conversion_factor),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(conversionFactor!.translate(context)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal, bottom: Dimens.marginNormal),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(AppLocalizations.of(context)!.cooking_method),
                          ),
                          Expanded(
                              flex: 1,
                              // TODO: buscar en la tabla de cooking methods.
                              child: Text(cookingMethod.isEmpty ? 'None' : cookingMethod),
                          ),
                        ],
                      ),
                    ),
                    if (!usedOil.isNull()) Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal, bottom: Dimens.marginNormal),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(AppLocalizations.of(context)!.oil_used),
                          ),
                          Expanded(
                            flex: 1,
                            // TODO: buscar en la tabla de cooking methods.
                            child: Text(usedOil!.translate(context)),
                          ),
                        ],
                      ),
                    ),
                    (editFood != null) ? Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => editFood?.call(),
                        icon: const Icon(Icons.edit),
                      ),
                    ) : const SizedBox(height: Dimens.heightXXSmall,),
                  ],
                ),
              ),
            ),
            if(int.parse(quantity) < 0) Container(margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),child: Text(AppLocalizations.of(context)!.must_complete_field, style: TextStyle(color: Colors.red,)),alignment: Alignment.centerLeft,)
          ],
        ),
      ),
    );
  }

}