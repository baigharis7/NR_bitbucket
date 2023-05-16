// ignore_for_file: overridden_fields
import 'dart:core';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class DietType {
  String? name;
  int? id;
  String icon;

  DietType({
    required this.name,
    this.id,
    required this.icon,
  });

  static List<DietType> listAllDietTypes() {
    return [
      Omnivorous(),
      Vegetarian(),
      LactoOvoVegetarian(),
      LactoVegetarian(),
      OvoVegetarian(),
      Vegan(),
      Halal(),
      Kosher(),
      Hindu(),
    ];
  }
  static List<DietType> listInitialDietTypes() {
    return [
      Omnivorous(),
      Vegetarian(),
      Vegan(),
      Halal(),
      Kosher(),
      Hindu(),
    ];
  }

  static List<DietType> listVegetariansTypes() {
    return [
      LactoOvoVegetarian(),
      LactoVegetarian(),
      OvoVegetarian(),
    ];
  }

  static List<DietType> listAllDietsButVegetarian() {
    return [
      Omnivorous(),
      LactoOvoVegetarian(),
      LactoVegetarian(),
      OvoVegetarian(),
      Vegan(),
      Halal(),
      Kosher(),
      Hindu(),
    ];
  }
}

class Omnivorous extends DietType {
  Omnivorous(): super(
    name: AppLocalizationsHelper.instance.translate('omnivorous'),
    id: -1,
    icon: 'assets/icon/omnivorous_icon.png',
  );
}

class Vegetarian extends DietType {
  Vegetarian(): super(
    name: AppLocalizationsHelper.instance.translate('vegetarian'),
    id: -2,
    icon: 'assets/icon/tree_icon.png',
  );
}

class Vegan extends DietType {
  Vegan(): super(
    name: AppLocalizationsHelper.instance.translate('vegan'),
    id: 15,
      icon: 'assets/icon/tree_icon.png',
  );
}

class Halal extends DietType {
  Halal(): super(
    name: AppLocalizationsHelper.instance.translate('halal'),
    id: 16,
    icon: 'assets/icon/meat_icon.png',
  );
}

class LactoOvoVegetarian extends DietType {
  LactoOvoVegetarian(): super(
    name: AppLocalizationsHelper.instance.translate('lactoovovegetarian'),
    id: 14,
    icon: 'assets/icon/tree_icon.png',
  );
}

class LactoVegetarian extends DietType {
  LactoVegetarian(): super(
    name: AppLocalizationsHelper.instance.translate('lactovegetarian'),
    id: 17,
    icon: 'assets/icon/tree_icon.png',
  );
}

class OvoVegetarian extends DietType {
  OvoVegetarian(): super(
    name: AppLocalizationsHelper.instance.translate('ovovegetarian'),
    id: 18,
    icon: 'assets/icon/tree_icon.png',
  );
}

class Kosher extends DietType {
  Kosher(): super(
    name: AppLocalizationsHelper.instance.translate('kosher'),
    id: 19,
    icon: 'assets/icon/meat_icon.png',
  );
}

class Hindu extends DietType {
  Hindu(): super(
    name: AppLocalizationsHelper.instance.translate('hindu'),
    id: 20,
    icon: 'assets/icon/meat_icon.png',
  );

}