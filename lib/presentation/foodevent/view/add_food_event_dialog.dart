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
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class AddFoodEventDialog extends StatefulWidget {
  final FoodInEvent foodInEvent;
  final String currentLanguage;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;
  final UnitsInfoMaster unitsInfoMaster;
  final UnitsFoodsMaster unitsFoodsMaster;

  const AddFoodEventDialog({
    Key? key,
    required this.foodInEvent,
    required this.currentLanguage,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.cookingMethodsInfoMaster,
    required this.unitsInfoMaster,
    required this.unitsFoodsMaster,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodEventItem();
}

class _AddFoodEventItem extends State<AddFoodEventDialog> {
  final _quantityController = TextEditingController();
  String? _cookingMethodName;
  String? _unitName;

  List<SimpleItem> findCookingMethodsForFood(String foodGroup, BuildContext context) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    final List<int> groupCookingMethods = widget.cookingMethodsMaster.cookingMethods.firstWhere(
          (cookingMethod) => cookingMethod.group == foodGroup,
      orElse: () => CookingMethod.empty(),
    ).methods;
    final cookingMethodsInfo = groupCookingMethods.map((cookingMethodId) {
      String name = widget.cookingMethodsInfoMaster.cookingMethodsInfo!
          .firstWhere((methodInfo) => methodInfo.id == cookingMethodId)
          .translate(context);
      return SimpleItem(name: name, id: cookingMethodId);
    });

    return cookingMethodsInfo.toList();
  }

  String findCookingMethodName(BuildContext context, int cookingMethod) {
    final cookingMethodInfo = widget.cookingMethodsInfoMaster.cookingMethodsInfo!
        .firstWhere((cookingMethodInfo) => cookingMethodInfo.id == cookingMethod, orElse: () => CookingMethodInfo());
    if (cookingMethodInfo.id == null) {
      return '';
    } else {
      return cookingMethodInfo.translate(context);
    }
  }

  List<SimpleItem> findUnitsForFood(int foodId, BuildContext context) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    String units = widget.unitsFoodsMaster.unitsFoodsMaster.firstWhere(
          (unitFood) => unitFood.id == foodId,
      orElse: () => UnitFoodMaster.empty(),
    ).units;
    List<SimpleItem> unitsList = [];

    units = units.isEmpty ? '-1,1' : units + '|-1,1';
    if (units.isNotEmptyOrNull()) {
      unitsList.addAll(units.split('|').map((unit) {
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
    widget.unitsInfoMaster.unitsInfoMaster.add(UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'));
    final unitInfo = widget.unitsInfoMaster.unitsInfoMaster
        .firstWhere((unitInfo) => unitInfo.id == unitId, orElse: () => UnitInfoMaster.empty());
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
    if (widget.foodInEvent.qty != 0) _quantityController.text = widget.foodInEvent.qty.toString();
    FoodInEvent ingredient = FoodInEvent(id: widget.foodInEvent.id, qty: 0, unit: 0, cookingMethod: -1);
    final mediaQuerySize = MediaQuery.of(context).size;

    if (ingredient.qty != 0) _quantityController.text = ingredient.qty.toString();
    List<SimpleItem> cookingMethods = findCookingMethodsForFood(widget.foodGroup, context);
    List<SimpleItem> units = findUnitsForFood(widget.foodInEvent.id, context);
    String unitsEquivalences = widget.unitsFoodsMaster.unitsFoodsMaster.firstWhere(
          (unitFood) => unitFood.id == widget.foodInEvent.id,
    ).units;

    if (widget.foodInEvent.cookingMethod != -1) {
      _cookingMethodName = _cookingMethodName ?? cookingMethods
          .firstWhere((cookingMethod) => cookingMethod.id == widget.foodInEvent.cookingMethod).name;
    }

    _unitName = _unitName ?? units
        .firstWhere((unit) => unit.id == widget.foodInEvent.unit).name;

    return SizedBox(
      width: mediaQuerySize.width,
      child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge),
                  child: Text('${AppLocalizations.of(context)!.quantity}:'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: Dimens.marginNormal),
                    margin: const EdgeInsets.only(right: Dimens.marginLarge, left: Dimens.marginSmall),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.write_here_hint,
                        alignLabelWithHint: true,
                      ),
                      onChanged: (qty) => ingredient.qty = int.parse(qty),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: units.isNotEmpty ?
                  Container(
                    margin: const EdgeInsets.only(
                      left: Dimens.marginNormal,
                      right: Dimens.marginNormal,
                      top: Dimens.marginLarge,
                    ),
                    child: SizedBox(
                      child: DropdownButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        value: _unitName,
                        onChanged: (String? unit) {
                          setState(() {
                            _unitName = unit!;
                            ingredient.unit = SimpleItemHelper().findSimpleItemId(units, unit);
                          });
                        },
                        items: units.map<DropdownMenuItem<String>>((item) => DropdownMenuItem(
                          value: item.name,
                          child: SizedBox(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: Dimens.fontSizeNormal,
                              ),
                            ),
                          ),),
                        ).toList(),
                      ),
                    ),
                  )
                      : Text(AppLocalizations.of(context)!.grames.toLowerCase()),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.cooking_method),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
              child: Row(
                children: [
                  if (cookingMethods.isEmpty) Center(
                    child: Text(AppLocalizations.of(context)!.none),)
                  else SizedBox(
                    child: DropdownButton<String>(
                      // icon: const Icon(Icons.arrow_drop_down),
                      value: _cookingMethodName,
                      onChanged: (String? cookingMethodNamed) {
                        setState(() {
                          _cookingMethodName = cookingMethodNamed ?? '';
                          ingredient.cookingMethod = SimpleItemHelper().findSimpleItemId(cookingMethods, cookingMethodNamed ?? '');
                        });
                        },
                      items: cookingMethods.map<DropdownMenuItem<String>>((item) => DropdownMenuItem(
                        value: item.name,
                        child: SizedBox(
                          width: mediaQuerySize.width/2,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: Dimens.fontSizeNormal,
                            ),
                          ),
                        ),),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                if (_quantityController.text != '' && _quantityController.text != '0' && ((units.isNotEmpty && _unitName != '') || (units.isEmpty)) && ((cookingMethods.isNotEmpty && _cookingMethodName != '') || cookingMethods.isEmpty)) {
                  final foodInEvent = FoodInEvent(
                    id: ingredient.id,
                    qty: int.parse(_quantityController.text),
                    unit: SimpleItemHelper().findSimpleItemId(units, _unitName!),
                    cookingMethod: SimpleItemHelper().findSimpleItemId(cookingMethods, _cookingMethodName ?? '-1'),
                    unitsEquivalences: unitsEquivalences,
                  );
                  Navigator.pop(context, foodInEvent);
                } else {
                  ToastHelper().showToast(text: AppLocalizations.of(context)!.missing_fieds_food_event);
                }
                },
              child: Text(AppLocalizations.of(context)!.finish, style: const TextStyle(color: Colors.white),),
            )
          ],
      ),
    );
  }

}