import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

extension NullableStringExtensions on String? {
  bool isNotEmptyOrNull() {
    if (this != null && this != '') {
      return true;
    } else {
      return false;
    }
  }

  bool isEmptyOrNull() {
    if (this == null || this == '') {
      return true;
    } else {
      return false;
    }
  }

  String orEmpty() {
    if (this == null) {
      return '';
    } else {
      return this!;
    }
  }

  bool isNull() {
    if (this == null) {
      return true;
    } else {
      return false;
    }
  }

  bool isNotNull() {
    if (this == null) {
      return false;
    } else {
      return true;
    }
  }
}

extension StringExtensions on String {
  bool isNotEmpty() {
    if (this != '') {
      return true;
    } else {
      return false;
    }
  }

  bool isEmpty() {
    if (this == '') {
      return true;
    } else {
      return false;
    }
  }

  String appendColon() {
    return '$this:';
  }

  String appendGram() {
    return '$this g';
  }
}

extension ListExtensions<T> on List<T> {

  String convertToBinary(int binarySize) {
    String binary = '';
    for (int i = 0; i < binarySize; i++) {
      if (contains(i)) {
        binary += '1';
      } else {
        binary += '0';
      }
    }
    return binary;
  }
}

extension NullableListExtensions<T> on List<T>? {
  List<T> orEmpty() {
    if (this == null) {
      return <T>[];
    } else {
      return this!;
    }
  }

}

extension PrefsKeysExtensions on PrefsKeys {
  String getKey() => name.orEmpty();
}

extension IntExtensions on int? {
  int getHiveKey() => this!~/(1000000);

  int orZero() {
    if (this == null) {
      return 0;
    } else {
      return this!;
    }
  }
}

extension ObjectExtensions on Object? {
  bool isNull() {
    if (this == null) {
      return true;
    } else {
      return false;
    }
  }

  bool aintNull(Function action) {
    if (this == null) {
      return false;
    } else {
      return true;
    }
  }

  void doIfNull(Function action) {
    if (this == null) {
      action.call();
    }
  }

  void doIfAintNull(Function action) {
    if (this != null) {
      action.call();
    }
  }

}

extension BoolExtensions on bool {
  void doIfTrue(Function action) {
    if (this) {
      action.call();
    }
  }

  void doIfFalse(Function action) {
    if (!this) {
      action.call();
    }
  }
}

extension DoubleExtensions on double? {
  double orZero() {
    if (this == null) {
      return 0.0;
    } else {
      return this!;
    }
  }
}

extension LanguageSelector<T> on T {
  String translate(BuildContext context) {
    if (this is Translatable) {
      String language = Localizations.localeOf(context).languageCode;
      if (this is ObjectiveInfoMaster) {
        if (language == 'es') {
          return (this as ObjectiveInfoMaster).es;
        } else {
          return (this as ObjectiveInfoMaster).en;
        }
      } else if (this is FoodItemMaster) {
        if (language == 'es') {
          return (this as FoodItemMaster).es.orEmpty();
        } else {
          return (this as FoodItemMaster).en.orEmpty();
        }
      } else if (this is NutrientInfoMaster) {
        if (language == 'es') {
          return (this as NutrientInfoMaster).es.orEmpty();
        } else {
          return (this as NutrientInfoMaster).en.orEmpty();
        }
      } else if (this is CookingMethodInfo) {
        if (language == 'es') {
          return (this as CookingMethodInfo).es.orEmpty();
        } else {
          return (this as CookingMethodInfo).en.orEmpty();
        }
      } else if (this is UnitInfoMaster) {
        if (language == 'es') {
          return (this as UnitInfoMaster).es.orEmpty();
        } else {
          return (this as UnitInfoMaster).en.orEmpty();
        }
      } else if (this is RecommendationGroup) {
        if (language == 'es') {
          return (this as RecommendationGroup).es.orEmpty();
        } else {
          return (this as RecommendationGroup).en.orEmpty();
        }
      } else if (this is SportInfoMaster) {
        if (language == 'es') {
          return (this as SportInfoMaster).es.orEmpty();
        } else {
          return (this as SportInfoMaster).en.orEmpty();
        }
      } else if (this is FoodInfo) {
        if (language == 'es') {
          return (this as FoodInfo).name_es.orEmpty();
        } else {
          return (this as FoodInfo).name_en.orEmpty();
        }
      } else if (this is SportEventInfo) {
        if (language == 'es') {
          return (this as SportEventInfo).name_es.orEmpty();
        } else {
          return (this as SportEventInfo).name_en.orEmpty();
        }
      } else if (this is FoodInFavorite) {
        if (language == 'es') {
          return (this as FoodInFavorite).name_es.orEmpty();
        } else {
          return (this as FoodInFavorite).name_en.orEmpty();
        }
      } else if (this is SportFavorite) {
        if (language == 'es') {
          return (this as SportFavorite).name_es.orEmpty();
        } else {
          return (this as SportFavorite).name_en.orEmpty();
        }
      } else if (this is RecipeMaster) {
        if (language == 'es') {
          return (this as RecipeMaster).name_es.orEmpty();
        } else {
          return (this as RecipeMaster).name_en.orEmpty();
        }
      } else if (this is SportInfo) {
        if (language == 'es') {
          return (this as SportInfo).name_es.orEmpty();
        } else {
          return (this as SportInfo).name_en.orEmpty();
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}

extension GetAllFoodNames on FoodsAndDrinkListsMaster {
  List<FoodItemMaster> getFoodsAndDrinkNamesOrEmpty() => [...drinkNames!.toList(), ...foodNames!.toList()];
}