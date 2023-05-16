// ignore_for_file: overridden_fields
import 'dart:core';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class ActivityByOccupationType {
  String? typeName;
  String? explanation;
  double? physicalActivityFactor;
  Function? action;

  ActivityByOccupationType({
    required this.typeName,
    required this.explanation,
    required this.physicalActivityFactor,
    this.action,
  });

  static List<ActivityByOccupationType> listAllActivityTypes() {
    return [
      ReposeActivity(),
      VeryLightActivity(),
      LightActivity(),
      ModerateActivity(),
      IntenseActivity(),
      VeryIntenseActivity(),
    ];
  }
}

class ReposeActivity extends ActivityByOccupationType {
  ReposeActivity() : super(
    typeName: AppLocalizationsHelper.instance.translate('repose'),
    explanation: AppLocalizationsHelper.instance.translate('repose_explanation'),
    physicalActivityFactor: 1.2,
  );
}

class VeryLightActivity extends ActivityByOccupationType {
  VeryLightActivity() : super(
    typeName: AppLocalizationsHelper.instance.translate('very_light_activity'),
    explanation: AppLocalizationsHelper.instance.translate('very_light_activity_explanation'),
    physicalActivityFactor: 1.45,
  );
}

class LightActivity extends ActivityByOccupationType {
  LightActivity() : super(
    typeName: AppLocalizationsHelper.instance.translate('light_activity'),
    explanation: AppLocalizationsHelper.instance.translate('light_activity_explanation'),
    physicalActivityFactor: 1.65,
  );
}

class ModerateActivity extends ActivityByOccupationType {
  ModerateActivity() : super(
    typeName: AppLocalizationsHelper.instance.translate('moderated_activity'),
    explanation: AppLocalizationsHelper.instance.translate('moderated_activity_explanation'),
    physicalActivityFactor: 1.85,
  );
}

class IntenseActivity extends ActivityByOccupationType {
  IntenseActivity() : super(
    typeName: AppLocalizationsHelper.instance.translate('intense_activity'),
    explanation: AppLocalizationsHelper.instance.translate('intense_activity_explanation'),
    physicalActivityFactor: 2.25,
  );
}

class VeryIntenseActivity extends ActivityByOccupationType {
  VeryIntenseActivity() :super(
    typeName: AppLocalizationsHelper.instance.translate('very_intense_activity'),
    explanation: AppLocalizationsHelper.instance.translate('very_intense_activity_explanation'),
    physicalActivityFactor: 2.5,
  );
}