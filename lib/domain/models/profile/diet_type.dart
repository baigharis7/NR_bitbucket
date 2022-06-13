// ignore_for_file: overridden_fields
import 'dart:core';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class DietType {
  String? name;
  int? id;

  DietType();

  static List<DietType> listAllDietTypes() {
    return [
      // Omnivorous(name: AppLocalizationsHelper.instance.translate('omnivorous')),
      Vegetarian(),
      Vegan(),
      Halal(),
    ];
  }
}

class Omnivorous extends DietType {
  @override
  String? name;

  Omnivorous(): super();
}

class Vegetarian extends DietType {
  @override
  String? name = AppLocalizationsHelper.instance.translate('vegetarian');
  @override
  int? id = 14;
  
  Vegetarian(): super();
}

class Vegan extends DietType {
  @override
  String? name = AppLocalizationsHelper.instance.translate('vegan');
  @override
  int? id = 15;

  Vegan(): super();
}

class Halal extends DietType {
  @override
  String? name = AppLocalizationsHelper.instance.translate('halal');
  @override
  int? id = 16;

  Halal(): super();
}