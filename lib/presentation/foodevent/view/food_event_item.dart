import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:nutrenaissance_flutter/presentation/widgets/box_type_radio_text_widget.dart';

class FoodEventItem extends StatefulWidget {
  final FoodInEvent foodInEvent;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;
  final UnitsInfoMaster unitsInfoMaster;
  final UnitsFoodsMaster unitsFoodsMaster;
  final String options;
  final Function onRemove;
  final Function(FoodInEvent) onQtyChange;
  final Function(FoodInEvent) onUnitChange;
  final Function(FoodInEvent) onCookingMethodChange;

  const FoodEventItem({
    Key? key,
    required this.foodInEvent,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.cookingMethodsInfoMaster,
    required this.unitsInfoMaster,
    required this.unitsFoodsMaster,
    required this.options,
    required this.onRemove,
    required this.onQtyChange,
    required this.onUnitChange,
    required this.onCookingMethodChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FoodEventItemState();
}

class _FoodEventItemState extends State<FoodEventItem> {
  final _quantityController = TextEditingController();
  String? _cookingMethodName;
  String? _unitName;
  bool _error = false;

  List<SimpleItem> findCookingMethodsForFood(
      String foodGroup, BuildContext context) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    List<int> groupCookingMethods =
        widget.cookingMethodsMaster.cookingMethods
            .firstWhere(
              (cookingMethod) => cookingMethod.group == foodGroup,
              orElse: () => CookingMethod.empty(),
            )
            .methods;
    final cookingMethodsInfo = groupCookingMethods.map((cookingMethodId) {
      String name = widget.cookingMethodsInfoMaster.cookingMethodsInfo!
          .firstWhere((methodInfo) => methodInfo.id == cookingMethodId)
          .translate(context);
      return SimpleItem(name: name, id: cookingMethodId);
    });

    return cookingMethodsInfo.toList();
  }

  String findCookingMethodName(BuildContext context, int cookingMethod) {
    final cookingMethodInfo =
        widget.cookingMethodsInfoMaster.cookingMethodsInfo!.firstWhere(
            (cookingMethodInfo) => cookingMethodInfo.id == cookingMethod,
            orElse: () => CookingMethodInfo());
    if (cookingMethodInfo.id == null) {
      return '';
    } else {
      return cookingMethodInfo.translate(context);
    }
  }

  List<SimpleItem> findUnitsForFood(int foodId, BuildContext context) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    String units = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere(
          (unitFood) => unitFood.id == foodId,
          orElse: () => UnitFoodMaster.empty(),
        )
        .units;
    List<SimpleItem> unitsList = [];

    units = units.isEmpty ? '-1,1' : units + '|-1,1';
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
    FoodInEvent ingredient = FoodInEvent(
        id: widget.foodInEvent.id, qty: 0, unit: -1, cookingMethod: -1);
    final mediaQuerySize = MediaQuery.of(context).size;

    // if (ingredient.qty != 0) _quantityController.text = ingredient.qty.toString();
    List<SimpleItem> cookingMethods =
        findCookingMethodsForFood(widget.foodGroup, context);
    _cookingMethodName = cookingMethods.isNotEmpty ? null : '';
    List<SimpleItem> units = findUnitsForFood(widget.foodInEvent.id, context);
    String unitsEquivalences = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere(
          (unitFood) => unitFood.id == widget.foodInEvent.id,
        orElse: () => UnitFoodMaster.empty(),)
        .units;
    ingredient.unitsEquivalences = unitsEquivalences;

    if (widget.foodInEvent.qty != 0 && _quantityController.text == '') {
      _quantityController.text = widget.foodInEvent.qty.toString();
      ingredient.qty = widget.foodInEvent.qty;
    }

    // if (widget.foodInEvent.cookingMethod != -1) {
      _cookingMethodName = _cookingMethodName ??
          cookingMethods
              .firstWhere((cookingMethod) =>
                  cookingMethod.id == widget.foodInEvent.cookingMethod)
              .name;
      ingredient.cookingMethod = widget.foodInEvent.cookingMethod;
    // }

    // if (widget.foodInEvent.unit != -1) {
      _unitName = _unitName ??
          units.firstWhere((unit) => unit.id == widget.foodInEvent.unit).name;
      ingredient.unit = widget.foodInEvent.unit;
    // }

    _error = widget.foodInEvent.qty == 0 || _cookingMethodName.isNull();
    // _error = widget.foodInEvent.qty == 0 || widget.foodInEvent.unit == 0;
    // _error = widget.foodInEvent.qty == 0 || widget.foodInEvent.unit == -1 || widget.foodInEvent.cookingMethod == -1;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(BorderSide(color: _error ? AppColors.errorRed : AppColors.cardGreen_200, width: 2)),
              borderRadius: BorderRadius.circular(5),
              color: _error ? AppColors.dirty_white : AppColors.cardGreen_200,),
          margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.options,
                        style: const TextStyle(fontSize: Dimens.fontSizeMedium),
                      ),
                    ),
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
                                            overflow: TextOverflow.ellipsis,
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
                      child: Text(AppLocalizations.of(context)!.cooking_method),
                    ),
                    const SizedBox(width: Dimens.widthXXXXSmall),
                    Expanded(
                      flex: 2,
                      child: (cookingMethods.isEmpty)
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
                              child: DropdownButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                isExpanded: true,
                                value: _cookingMethodName,
                                onChanged: (String? cookingMethodNamed) {
                                  // setState(() {
                                  _cookingMethodName = cookingMethodNamed ?? '';
                                  ingredient.cookingMethod = SimpleItemHelper()
                                      .findSimpleItemId(
                                          cookingMethods, cookingMethodNamed ?? '');
                                  widget.onCookingMethodChange.call(ingredient);
                                  // });
                                },
                                items: cookingMethods
                                    .map<DropdownMenuItem<String>>(
                                      (item) => DropdownMenuItem(
                                        value: item.name,
                                        child: SizedBox(
                                          child: Text(
                                            item.name,
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
        if (_error) Container(child: Text(AppLocalizations.of(context)!.must_complete_field, style: const TextStyle(color: Colors.red,)),alignment: Alignment.centerLeft,),
      ],
    );
  }
}
