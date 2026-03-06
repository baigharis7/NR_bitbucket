import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/simple_item_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../../../data/api/masterfiles/model/conversion_factors_response.dart';
import '../../../../data/api/masterfiles/model/oil_types_response.dart';
import '../../../../domain/models/favorites/food/food_favorite.dart';
import '../../../../infrastructure/utils/constants.dart';
import '../../../widgets/radio_button_with_text.dart';

class FoodFavItem extends StatefulWidget {
  final FoodInFavorite foodInFavorite;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;
  final OilTypesResponse? oilTypes;
  final ConversionFactorsResponse? conversionFactors;
  final UnitsInfoMaster unitsInfoMaster;
  final UnitsFoodsMaster unitsFoodsMaster;
  final String options;
  final Function onRemove;
  final Function(FoodInFavorite) onQtyChange;
  final Function(FoodInFavorite) onUnitChange;
  final Function(FoodInFavorite) onCookingMethodChange;
  final Function(FoodInFavorite) onConversionFactorChange;
  final Function(FoodInFavorite) onOilUsedChange;

  const FoodFavItem({
    Key? key,
    required this.foodInFavorite,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.cookingMethodsInfoMaster,
    this.conversionFactors,
    this.oilTypes,
    required this.unitsInfoMaster,
    required this.unitsFoodsMaster,
    required this.options,
    required this.onRemove,
    required this.onQtyChange,
    required this.onUnitChange,
    required this.onCookingMethodChange,
    required this.onConversionFactorChange,
    required this.onOilUsedChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodFavItemState();
}

class _FoodFavItemState extends State<FoodFavItem> {
  final _quantityController = TextEditingController();
  String? _cookingMethodName;
  String? _unitName;
  bool _error = false;

  // List<SimpleItem> findCookingMethodsForFood(
  //     String foodGroup, BuildContext context) {
  //   // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
  //   final List<int> groupCookingMethods =
  //       widget.cookingMethodsMaster.cookingMethods
  //           .firstWhere(
  //             (cookingMethod) => cookingMethod.group == foodGroup,
  //             orElse: () => CookingMethod.empty(),
  //           )
  //           .methods;
  //   final cookingMethodsInfo = groupCookingMethods.map((cookingMethodId) {
  //     String name = widget.cookingMethodsInfoMaster.cookingMethodsInfo!
  //         .firstWhere((methodInfo) => methodInfo.id == cookingMethodId)
  //         .translate(context);
  //     return SimpleItem(name: name, id: cookingMethodId);
  //   });
  //
  //   return cookingMethodsInfo.toList();
  // }
  //
  // String findCookingMethodName(BuildContext context, int cookingMethod) {
  //   final cookingMethodInfo =
  //       widget.cookingMethodsInfoMaster.cookingMethodsInfo!.firstWhere(
  //           (cookingMethodInfo) => cookingMethodInfo.id == cookingMethod,
  //           orElse: () => CookingMethodInfo());
  //   if (cookingMethodInfo.id == null) {
  //     return '';
  //   } else {
  //     return cookingMethodInfo.translate(context);
  //   }
  // }

  List<SimpleItem> findUnitsForFood(int foodId, BuildContext context) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    String units = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere(
          (unitFood) => unitFood.id == foodId,
          orElse: () => UnitFoodMaster.empty(),
        )
        .units;
    List<SimpleItem> unitsList = [];

    units = units.isEmpty ? '-1,1|-2,2' : units.replaceRange(0, 0, '-1,1|-2,2|');
    if (units.isNotEmptyOrNull()) {
      unitsList.addAll(
        units.split('|').map((unit) {
          final unitId = int.parse(unit.split(',')[0]);
          String name = widget.unitsInfoMaster.unitsInfoMaster
              .firstWhere((unitInfo) => unitInfo.id == unitId)
              .translate(context);
          return SimpleItem(name: name, id: unitId);
        }),
      );
    }

    return unitsList;
  }

  String findUnitName(BuildContext context, int unitId) {
    /** REMOVE THIS AFTER NEXT LOGIN*/
    widget.unitsInfoMaster.unitsInfoMaster
        .add(UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'));
    final unitInfo = widget.unitsInfoMaster.unitsInfoMaster.firstWhere(
        (unitInfo) => unitInfo.id == unitId,
        orElse: () => UnitInfoMaster.empty());
    if (unitInfo.id == 0) {
      return '';
    } else {
      return unitInfo.translate(context);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FoodInFavorite ingredient = FoodInFavorite(id: widget.foodInFavorite.id, name_en: widget.foodInFavorite.name_en.orEmpty(), name_es: widget.foodInFavorite.name_es.orEmpty(), qty: widget.foodInFavorite.qty, unit: -1, conversionFactor: widget.foodInFavorite.conversionFactor, cookingMethod: widget.foodInFavorite.cookingMethod, usedOil: widget.foodInFavorite.usedOil);
    final mediaQuerySize = MediaQuery.of(context).size;

    // if (ingredient.qty != 0) _quantityController.text = ingredient.qty.toString();
    // List<SimpleItem> cookingMethods =
    //     findCookingMethodsForFood(widget.foodGroup, context);
    // _cookingMethodName = cookingMethods.isNotEmpty ? null : '';
    List<SimpleItem> units = findUnitsForFood(widget.foodInFavorite.id, context);
    String unitsEquivalences = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere(
          (unitFood) => unitFood.id == widget.foodInFavorite.id,
        )
        .units;
    ingredient.unitsEquivalences = unitsEquivalences;

    // if (widget.foodInFavorite.qty != 0 && _quantityController.text == '') {
    //   _quantityController.text = widget.foodInFavorite.qty.toString();
      _quantityController.text = ingredient.qty.toString();
    //   ingredient.qty = widget.foodInFavorite.qty;
    // }

    // if (widget.foodInFavorite.cookingMethod != -1) {
    //   _cookingMethodName = _cookingMethodName ??
    //       cookingMethods
    //           .firstWhere((cookingMethod) =>
    //               cookingMethod.id == widget.foodInFavorite.cookingMethod)
    //           .name;
    //   ingredient.cookingMethod = widget.foodInFavorite.cookingMethod;
    // }

    // if (widget.foodInEvent.unit != -1) {
      _unitName = _unitName ??
          units.firstWhere((unit) => unit.id == widget.foodInFavorite.unit).name;
      ingredient.unit = widget.foodInFavorite.unit;
    // }

    _error = ingredient.qty <= 0 || ingredient.unit == -1 || ingredient.conversionFactor.orZero() < 0  || (ingredient.conversionFactor == Constants.CONVERSION_FACTOR_COOKED && ingredient.cookingMethod == -1);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(BorderSide(color: _error ? AppColors.errorRed : AppColors.cardGreen_200, width: 2)),
              borderRadius: BorderRadius.circular(5),
              color: _error ? AppColors.dirty_white : AppColors.cardGreen_200,),
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal,),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
                child: Row(
                  children: [
                    Text(
                      widget.options,
                      style: const TextStyle(fontSize: Dimens.fontSizeMedium),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => widget.onRemove.call(),
                      child: const Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        AppLocalizations.of(context)!.quantity,
                      ),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (qty) {
                          ingredient.qty = qty.isEmpty ? 0 : int.parse(qty);
                          widget.onQtyChange.call(ingredient);
                        },
                      ),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      child: units.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimens.paddingSmall),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.black54, width: 1))),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: Container(),
                                icon: const Icon(Icons.arrow_drop_down),
                                value: _unitName,
                                onChanged: (String? unit) {
                                  // setState(() {
                                  _unitName = unit!;
                                  ingredient.unit = SimpleItemHelper()
                                      .findSimpleItemId(units, unit);
                                  widget.onUnitChange.call(ingredient);
                                  // });
                                },
                                items: units
                                    .map<DropdownMenuItem<String>>(
                                      (item) => DropdownMenuItem(
                                        value: item.name,
                                        child: SizedBox(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: Dimens.fontSizeNormal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.grames.toLowerCase()),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.conversion_factor,
                      ),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    ...?widget.conversionFactors?.data.map((factor) =>
                        RadioButtonWithText(
                          value: factor.id,
                          text: factor.translate(context),
                          groupValue: ingredient.conversionFactor ?? -1,
                          onConversionFactorChange: (factorValue) {
                            ingredient.conversionFactor = factorValue;
                            widget.onConversionFactorChange.call(ingredient);
                          },
                        ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.cooking_method),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      flex: 2,
                      child: (widget.cookingMethodsInfoMaster.cookingMethodsInfo.orEmpty().isEmpty)
                          ? Center(
                              child: Text(AppLocalizations.of(context)!.none),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimens.paddingSmall),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.black54, width: 1))),
                              child: DropdownButton<int>(
                                icon: const Icon(Icons.arrow_drop_down),
                                isExpanded: true,
                                underline: Container(),
                                value: ingredient.cookingMethod,
                                onChanged: (int? cookingMethodId) {
                                  ingredient.cookingMethod = cookingMethodId!;
                                  widget.onCookingMethodChange.call(ingredient);
                                },
                                items: widget.cookingMethodsInfoMaster.cookingMethodsInfo.orEmpty()
                                    .map<DropdownMenuItem<int>>(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: SizedBox(
                                          child: Text(
                                            item.translate(context).orEmpty(),
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: Dimens.fontSizeNormal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              if (ingredient.cookingMethod == Constants.COOKING_METHOD_BREADED || ingredient.cookingMethod == Constants.COOKING_METHOD_FRIED) Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.oil_used),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.paddingSmall),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.all(Radius.circular(5)),
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.black54, width: 1))),
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          underline: Container(),
                          value: ingredient.usedOil,
                          onChanged: (int? oilId) {
                            ingredient.usedOil = oilId;
                            widget.onOilUsedChange.call(ingredient);
                          },
                          items: widget.oilTypes?.data
                              .map<DropdownMenuItem<int>>(
                                (item) => DropdownMenuItem(
                              value: item.id,
                              child: SizedBox(
                                child: Text(
                                  item.translate(context),
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: Dimens.fontSizeNormal,
                                  ),
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_error) Container(child: Text(AppLocalizations.of(context)!.must_complete_field, style: const TextStyle(color: Colors.red,)), alignment: Alignment.centerLeft,),
      ],
    );
  }
}
