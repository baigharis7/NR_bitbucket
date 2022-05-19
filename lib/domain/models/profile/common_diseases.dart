// ignore_for_file: overridden_fields

import 'dart:core';

import '../../../infrastructure/helpers/i10n_helper.dart';


class CommonDiseases {
  String? name;
  int? id;
  String? otherDiseases;

  CommonDiseases({this.name, this.otherDiseases});

  static List<CommonDiseases> listAllDiseases() {
    return [
      HighBloodPressure(name: AppLocalizations.instance.translate('high_blood_pressure')),
      Arteriosclerosis(name: AppLocalizations.instance.translate('arteriosclerosis')),
      Type1Diabetes(name: AppLocalizations.instance.translate('type_1_diabetes')),
      Type2Diabetes(name: AppLocalizations.instance.translate('type_2_diabetes')),
      HighSugarLevel(name: AppLocalizations.instance.translate('high_sugar_level')),
      HighCholesterol(name: AppLocalizations.instance.translate('high_cholesterol')),
      HighTriglycerides(name: AppLocalizations.instance.translate('high_triglycerides')),
      NoDiseases(name: AppLocalizations.instance.translate('other_diseases')),
      OtherDiseases(name: AppLocalizations.instance.translate('none'))
    ];
  }
}

class HighBloodPressure extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 0;
  @override
  String? otherDiseases;

  HighBloodPressure({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class Arteriosclerosis extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 1;
  @override
  String? otherDiseases;

  Arteriosclerosis({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class Type1Diabetes extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 2;
  @override
  String? otherDiseases;

  Type1Diabetes({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class Type2Diabetes extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 3;
  @override
  String? otherDiseases;

  Type2Diabetes({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class HighSugarLevel extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 4;
  @override
  String? otherDiseases;

  HighSugarLevel({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class HighCholesterol extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 5;
  @override
  String? otherDiseases;

  HighCholesterol({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class HighTriglycerides extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 6;
  @override
  String? otherDiseases;

  HighTriglycerides({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class OtherDiseases extends CommonDiseases {
  @override
  String? name;
  @override
  int? id = 7;
  @override
  String? otherDiseases;

  OtherDiseases({this.name, this.otherDiseases}):
        super(name: name, otherDiseases: otherDiseases);
}

class NoDiseases extends CommonDiseases {
  @override
  String? name;

  NoDiseases({this.name}):
        super(name: name);
}

