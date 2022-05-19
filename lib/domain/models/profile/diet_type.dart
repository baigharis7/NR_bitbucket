// ignore_for_file: overridden_fields

import 'dart:core';

import '../../../infrastructure/helpers/i10n_helper.dart';

class DietType {
  String? name;
  int? id;

  DietType({this.name});

  static List<DietType> listAllDietTypes() {
    return [
      // Omnivorous(name: AppLocalizations.instance.translate('omnivorous')),
      Vegetarian(name: AppLocalizations.instance.translate('vegetarian')),
      Vegan(name: AppLocalizations.instance.translate('vegan')),
      Halal(name: AppLocalizations.instance.translate('halal')),
    ];
  }
}

class Omnivorous extends DietType {
  @override
  String? name;

  Omnivorous({this.name}): super(name: name);
}

class Vegetarian extends DietType {
  @override
  String? name;
  @override
  int? id = 14;
  
  Vegetarian({this.name}): super(name: name);
}

class Vegan extends DietType {
  @override
  String? name;
  @override
  int? id = 15;

  Vegan({this.name}): super(name: name);
}

class Halal extends DietType {
  @override
  String? name;
  @override
  int? id = 16;

  Halal({this.name}): super(name: name);
}