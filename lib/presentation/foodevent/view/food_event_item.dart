import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_response.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/simple_item_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/box_type_radio_text_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/radio_button_with_text.dart';

import '../../../data/api/masterfiles/model/oil_types_response.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';

class FoodEventItem extends StatefulWidget {
  final FoodInFavorite foodInEvent;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final OilTypesResponse? oilTypes;
  final ConversionFactorsResponse? conversionFactors;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;
  final UnitsInfoMaster unitsInfoMaster;
  final UnitsFoodsMaster unitsFoodsMaster;
  final String options;
  final Function onRemove;
  final Function(FoodInFavorite) onQtyChange;
  final Function(FoodInFavorite) onUnitChange;
  final Function(FoodInFavorite) onCookingMethodChange;
  final Function(FoodInFavorite) onConversionFactorChange;
  final Function(FoodInFavorite) onOilUsedChange;
  final bool showValidation;

  const FoodEventItem({
    Key? key,
    required this.foodInEvent,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.oilTypes,
    required this.conversionFactors,
    required this.cookingMethodsInfoMaster,
    required this.unitsInfoMaster,
    required this.unitsFoodsMaster,
    required this.options,
    required this.onRemove,
    required this.onQtyChange,
    required this.onUnitChange,
    required this.onCookingMethodChange,
    required this.onConversionFactorChange,
    required this.onOilUsedChange,
    this.showValidation = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodEventItemState();
}

class _FoodEventItemState extends State<FoodEventItem> {
  final _quantityController = TextEditingController();
  String? _unitName;

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
              .firstWhere(
                (unitInfo) => unitInfo.id == unitId,
                orElse: () => UnitInfoMaster.empty(),
              )
              .translate(context);
          return SimpleItem(name: name, id: unitId);
        }),
      );
    }

    return unitsList;
  }

  String findUnitName(BuildContext context, int unitId) {
    /** REMOVE THIS AFTER NEXT LOGIN*/
    // widget.unitsInfoMaster.unitsInfoMaster
    //     .add(UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'));
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
    FoodInFavorite ingredient = FoodInFavorite(
      id: widget.foodInEvent.id,
      qty: widget.foodInEvent.qty,
      unit: widget.foodInEvent.unit,
      conversionFactor: widget.foodInEvent.conversionFactor,
      cookingMethod: widget.foodInEvent.cookingMethod,
      usedOil: widget.foodInEvent.usedOil,
    );

    List<SimpleItem> units = findUnitsForFood(widget.foodInEvent.id, context);

    String unitsEquivalences = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere(
          (unitFood) => unitFood.id == widget.foodInEvent.id,
        orElse: () => UnitFoodMaster.empty(),)
        .units;
    ingredient.unitsEquivalences = unitsEquivalences;

    final qtyText = ingredient.qty == 0 ? '' : ingredient.qty.toString();
    if (_quantityController.text != qtyText) {
      _quantityController.text = qtyText;
    }

    _unitName = _unitName ??
          units.firstWhere((unit) => unit.id == widget.foodInEvent.unit).name;
      ingredient.unit = widget.foodInEvent.unit;

    final missingQty = widget.foodInEvent.qty <= 0;
    final missingUnit = widget.foodInEvent.unit == -1;
    final missingCookingMethod = ingredient.conversionFactor == Constants.CONVERSION_FACTOR_COOKED && ingredient.cookingMethod == -1;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.white85Percent,),
          margin: const EdgeInsets.only(top: Dimens.marginSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.options,
                        style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.onRemove.call(),
                      child: const Icon(Icons.cancel_outlined, size: 28, color: AppColors.yellowishGreen),
                    ),
                  ],
                ),
              ),
              Text(AppLocalizations.of(context)!.amount, style: const TextStyle(color: AppColors.yellowishGreen, fontSize: Dimens.fontSizeNormal, fontWeight: FontWeight.w700)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        controller: _quantityController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingSmall),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(11)),
                            borderSide: BorderSide(color: widget.showValidation && missingQty ? AppColors.errorRed : AppColors.silver, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(11)),
                            borderSide: BorderSide(color: widget.showValidation && missingQty ? AppColors.errorRed : AppColors.silver, width: 1),
                          ),
                        ),
                        onChanged: (qty) {
                          ingredient.qty = qty.isEmpty ? 0 : int.parse(qty);
                          widget.onQtyChange.call(ingredient);
                        },
                      ),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      flex: 2,
                      child: units.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimens.paddingSmall),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(11)),
                                  border: Border.fromBorderSide(
                                      BorderSide(color: widget.showValidation && missingUnit ? AppColors.errorRed : AppColors.silver, width: 1))),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: Container(),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
                                value: units.firstWhere((u) => u.id == ingredient.unit, orElse: () => units.first).name,
                                onChanged: (String? unitName) {
                                  final unitId = SimpleItemHelper().findSimpleItemId(units, unitName!);
                                  ingredient.unit = unitId;
                                  widget.onUnitChange.call(ingredient);
                                },
                                items: units
                                    .map<DropdownMenuItem<String>>(
                                      (item) => DropdownMenuItem(
                                        value: item.name,
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: Dimens.fontSizeNormal,
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
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
              //   height: Dimens.heightSmall - 15,
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Text(
              //           AppLocalizations.of(context)!.conversion_factor,
              //         ),
              //       ),
              //       const SizedBox(width: Dimens.widthXXXXSmall),
              //       ...?widget.conversionFactors?.data.map((factor) =>
              //           RadioButtonWithText(
              //             value: factor.id,
              //             text: factor.translate(context),
              //             groupValue: ingredient.conversionFactor ?? -1,
              //             onConversionFactorChange: (factorValue) {
              //               ingredient.conversionFactor = factorValue;
              //               widget.onConversionFactorChange.call(ingredient);
              //             },
              //           ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(width: Dimens.widthXXXXSmall),
              Text(AppLocalizations.of(context)!.conversion_factor, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeNormal)),
              Row(
                children: [
                  Switch.adaptive(
                    value: ingredient.conversionFactor == 1,
                    inactiveTrackColor: Colors.grey.shade300,
                    inactiveThumbColor: Colors.white,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) return null;
                      return Colors.grey.shade400;
                    }),
                    thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.mountainMeadow;
                      }
                      return Colors.white;
                    }),
                    activeColor: Colors.white,
                    applyCupertinoTheme: true,
                    onChanged: (isChecked) {
                      ingredient.conversionFactor = isChecked ? 1 : 0;
                      widget.onConversionFactorChange.call(ingredient);
                    },
                  ),
                  Text(AppLocalizations.of(context)!.cooked, style: const TextStyle(fontSize: Dimens.fontSizeLarge, fontWeight: FontWeight.w400)),
                  if (ingredient.conversionFactor == Constants.CONVERSION_FACTOR_COOKED && widget.cookingMethodsInfoMaster.cookingMethodsInfo.orEmpty().isNotEmpty) ...[
                    const SizedBox(width: Dimens.paddingSmall),
                    Expanded(
                      child: Container(
                        height: Dimens.heightSmall - 15,
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(11)),
                            border: Border.fromBorderSide(BorderSide(color: widget.showValidation && missingCookingMethod ? AppColors.errorRed : AppColors.silver, width: 1))),
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
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
                                  alignment: Alignment.center,
                                  value: item.id,
                                  child: Text(
                                    item.translate(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: Dimens.fontSizeNormal,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if ((ingredient.cookingMethod == Constants.COOKING_METHOD_BREADED || ingredient.cookingMethod == Constants.COOKING_METHOD_FRIED) && widget.oilTypes?.data != null) Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                height: Dimens.heightSmall - 15,
                child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.paddingSmall),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(11)),
                            border: Border.fromBorderSide(
                                BorderSide(color: AppColors.silver, width: 1))),
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
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
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.translate(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: Dimens.fontSizeNormal,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
              if (widget.showValidation && missingQty) Padding(
                padding: const EdgeInsets.only(top: Dimens.marginSmall),
                child: Text(AppLocalizations.of(context)!.please_enter_amount, style: const TextStyle(color: AppColors.errorRed, fontSize: Dimens.fontSizeSmall)),
              ),
              if (widget.showValidation && missingUnit) Padding(
                padding: const EdgeInsets.only(top: Dimens.marginSmall),
                child: Text(AppLocalizations.of(context)!.please_select_unit, style: const TextStyle(color: AppColors.errorRed, fontSize: Dimens.fontSizeSmall)),
              ),
              if (widget.showValidation && missingCookingMethod) Padding(
                padding: const EdgeInsets.only(top: Dimens.marginSmall),
                child: Text(AppLocalizations.of(context)!.please_select_cooking_method, style: const TextStyle(color: AppColors.errorRed, fontSize: Dimens.fontSizeSmall)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
