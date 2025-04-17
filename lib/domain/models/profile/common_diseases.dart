// ignore_for_file: overridden_fields
import 'dart:core';

import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class CommonDiseases {
  String? name;
  int? id;
  String? otherDiseases;

  CommonDiseases({this.otherDiseases});

  static List<CommonDiseases> listAllDiseases() {
    return [
      NoneDisease(),
      HighBloodPressure(),
      Arteriosclerosis(),
      Type1Diabetes(),
      Type2Diabetes(),
      HighSugarLevel(),
      HighCholesterol(),
      HighTriglycerides(),
      // NoDiseases(),
      // OtherDiseases()
    ];
  }
}

class NoneDisease extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('none');
  @override
  int? id = -1;
  @override
  String? otherDiseases;

  NoneDisease({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class HighBloodPressure extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('high_blood_pressure');
  @override
  int? id = 0;
  @override
  String? otherDiseases;

  HighBloodPressure({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class Arteriosclerosis extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('arteriosclerosis');
  @override
  int? id = 1;
  @override
  String? otherDiseases;

  Arteriosclerosis({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class Type1Diabetes extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('type_1_diabetes');
  @override
  int? id = 2;
  @override
  String? otherDiseases;

  Type1Diabetes({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class Type2Diabetes extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('type_2_diabetes');
  @override
  int? id = 3;
  @override
  String? otherDiseases;

  Type2Diabetes({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class HighSugarLevel extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('high_sugar_level');
  @override
  int? id = 4;
  @override
  String? otherDiseases;

  HighSugarLevel({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class HighCholesterol extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('high_cholesterol');
  @override
  int? id = 5;
  @override
  String? otherDiseases;

  HighCholesterol({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

class HighTriglycerides extends CommonDiseases {
  @override
  String? name = AppLocalizationsHelper.instance.translate('high_triglycerides');
  @override
  int? id = 6;
  @override
  String? otherDiseases;

  HighTriglycerides({this.otherDiseases}):
        super(otherDiseases: otherDiseases);
}

// class OtherDiseases extends CommonDiseases {
//   @override
//   String? name = AppLocalizationsHelper.instance.translate('none');
//   @override
//   int? id = 7;
//   @override
//   String? otherDiseases;
//
//   OtherDiseases({this.otherDiseases}):
//         super(otherDiseases: otherDiseases);
// }

// class NoDiseases extends CommonDiseases {
//   @override
//   String? name = AppLocalizationsHelper.instance.translate('other_diseases');
//
//   NoDiseases():super();
// }

