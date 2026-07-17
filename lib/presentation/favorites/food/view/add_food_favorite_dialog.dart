import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/simple_item_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class AddFoodFavoriteDialog extends StatefulWidget {
  final FoodInFavorite foodInFavorite;
  final String foodGroup;
  final CookingMethodsMaster cookingMethodsMaster;
  final CookingMethodsInfoMaster cookingMethodsInfoMaster;
  final UnitsInfoMaster unitsInfoMaster;
  final UnitsFoodsMaster unitsFoodsMaster;

  const AddFoodFavoriteDialog({
    Key? key,
    required this.foodInFavorite,
    required this.foodGroup,
    required this.cookingMethodsMaster,
    required this.cookingMethodsInfoMaster,
    required this.unitsInfoMaster,
    required this.unitsFoodsMaster,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodFavoriteItem();
}

class _AddFoodFavoriteItem extends State<AddFoodFavoriteDialog> {
  final _quantityController = TextEditingController();
  final eventHelper = EventsHelper();
  final simpleItemHelper = SimpleItemHelper();
  String? _cookingMethodName;
  String? _unitName;

  String findUnitName(BuildContext context, int unitId) {
    /** REMOVE THIS AFTER NEXT LOGIN*/
    widget.unitsInfoMaster.unitsInfoMaster.add(UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'),);
    final unitInfo = widget.unitsInfoMaster.unitsInfoMaster
        .firstWhere((unitInfo) => unitInfo.id == unitId, orElse: () => UnitInfoMaster.empty(),);
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
    if (widget.foodInFavorite.qty != 0) {
      _quantityController.text = widget.foodInFavorite.qty.toString();
    }
    FoodInFavorite ingredient = FoodInFavorite(
      id: widget.foodInFavorite.id,
      name_en: widget.foodInFavorite.name_en,
      name_es: widget.foodInFavorite.name_es,
      qty: 0,
      unit: 0,
      cookingMethod: -1,
    );
    final mediaQuerySize = MediaQuery.of(context).size;

    if (ingredient.qty != 0) {
      _quantityController.text = ingredient.qty.toString();
    }
    List<SimpleItem> cookingMethods = simpleItemHelper.findCookingMethodsForFood(widget.foodGroup, context, widget.cookingMethodsMaster.cookingMethods, widget.cookingMethodsInfoMaster.cookingMethodsInfo!);
    List<SimpleItem> units = simpleItemHelper.findUnitsForFood(widget.foodInFavorite.id, context, widget.unitsFoodsMaster.unitsFoodsMaster, widget.unitsInfoMaster.unitsInfoMaster);
    String unitsEquivalences = widget.unitsFoodsMaster.unitsFoodsMaster
        .firstWhere((unitFood) => unitFood.id == widget.foodInFavorite.id,).units;

    if (widget.foodInFavorite.cookingMethod != -1) {
      _cookingMethodName = _cookingMethodName ?? cookingMethods
          .firstWhere((cookingMethod) => cookingMethod.id == widget.foodInFavorite.cookingMethod).name;
    }

    _unitName = _unitName ?? units
        .firstWhere((unit) => unit.id == widget.foodInFavorite.unit)
        .name;

    // Esto estaba en un SimpleDialog.
    return SizedBox(
      width: mediaQuerySize.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginLarge,),
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
                  margin: const EdgeInsets.only(
                      right: Dimens.marginLarge, left: Dimens.marginSmall,
                  ),
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
                          ingredient.unit =
                              SimpleItemHelper().findSimpleItemId(units, unit);
                        });
                      },
                      items: units.map<DropdownMenuItem<String>>((item) =>
                          DropdownMenuItem(
                            value: item.name,
                            child: SizedBox(
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
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
          if (Constants.cookingOptionsEnabled) Container(
            margin: const EdgeInsets.only(
              left: Dimens.marginNormal,
              top: Dimens.marginLarge,
            ),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.cooking_method),
          ),
          if (Constants.cookingOptionsEnabled) Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimens.marginNormal,
              vertical: Dimens.marginNormal,
            ),
            child: Row(
              children: [
                cookingMethods.isEmpty
                    ? Center(
                  child: Text(AppLocalizations.of(context)!.none),)
                    : SizedBox(
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: _cookingMethodName,
                    onChanged: (String? cookingMethodNamed) {
                      setState(() {
                        _cookingMethodName = cookingMethodNamed!;
                        ingredient.cookingMethod = simpleItemHelper.findSimpleItemId(cookingMethods, cookingMethodNamed,);
                      });
                    },
                    items: cookingMethods.map<DropdownMenuItem<String>>((item) => DropdownMenuItem(
                      value: item.name,
                      child: Text(
                        item.name,
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
              if (_quantityController.text != '' &&
                  _quantityController.text != '0' &&
                  ((units.isNotEmpty && _unitName != '') || (units.isEmpty)) &&
                  ((cookingMethods.isNotEmpty && _cookingMethodName != '') ||
                      cookingMethods.isEmpty)) {
                final foodInFavorite = FoodInFavorite(
                  id: ingredient.id,
                  name_en: ingredient.name_en,
                  name_es: ingredient.name_es,
                  qty: int.parse(_quantityController.text),
                  unit: SimpleItemHelper().findSimpleItemId(units, _unitName!),
                  cookingMethod: SimpleItemHelper().findSimpleItemId(cookingMethods, _cookingMethodName ?? '-1',),
                  unitsEquivalences: unitsEquivalences,
                );
                Navigator.pop(context, foodInFavorite);
              } else {
                ToastHelper().showToast(text: AppLocalizations.of(context)!.missing_fieds_food_event);
              }
            },
            child: Text(AppLocalizations.of(context)!.finish,
              style: const TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}