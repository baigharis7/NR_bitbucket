import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class SimpleItemHelper {
  SimpleItemHelper();

  int findSimpleItemId(List<SimpleItem> simpleItems, String name) {
    if (name == '-1') {
      return -1;
    } else {
      return simpleItems.firstWhere((simpleItem) => name == simpleItem.name).id;
    }
  }

  List<SimpleItem> findCookingMethodsForFood(String foodGroup, BuildContext context, List<CookingMethod> cookingMethods, List<CookingMethodInfo> cookingMethodsInfoList) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    final List<int> groupCookingMethods = cookingMethods
        .firstWhere((cookingMethod) => cookingMethod.group == foodGroup,
      orElse: () => CookingMethod.empty(),
    )
        .methods;
    final cookingMethodsInfo = groupCookingMethods.map((cookingMethodId) {
      String name = cookingMethodsInfoList
          .firstWhere((methodInfo) => methodInfo.id == cookingMethodId)
          .translate(context);
      return SimpleItem(name: name, id: cookingMethodId);
    });

    return cookingMethodsInfo.toList();
  }

  List<SimpleItem> findUnitsForFood(int foodId, BuildContext context, List<UnitFoodMaster> unitFoodsMaster, List<UnitInfoMaster> unitsInfoMasterList) {
    // TODO: quitar el orElse, es para subsanar que no aparecen todos los cooking methods en el JSON.
    String units = unitFoodsMaster
        .firstWhere((unitFood) => unitFood.id == foodId,
      orElse: () => UnitFoodMaster.empty(),
    ).units;
    List<SimpleItem> unitsList = [];

    units = units.isEmpty ? '-1,1|-2,2' : units.replaceRange(0, 0, '-1,1|-2,2|');
    if (units.isNotEmptyOrNull()) {
      unitsList.addAll(units.split('|').map((unit) {
        final unitId = int.parse(unit.split(',')[0]);
        String name = unitsInfoMasterList
            .firstWhere((unitInfo) => unitInfo.id == unitId)
            .translate(context);
        return SimpleItem(name: name, id: unitId);
      }),
      );
    }

    return unitsList;
  }

}