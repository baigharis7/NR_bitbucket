// ignore_for_file: overridden_fields
import 'dart:core';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';

class ActivityByOccupationType {
  String? typeName;
  String? explanation;
  double? physicalActivityFactor;
  Function? action;

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
  ActivityByOccupationType({this.action});
}

class ReposeActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('repose');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('repose_explanation');
  @override
  double? physicalActivityFactor = 1.2;
  @override
  Function? action;

  ReposeActivity({this.action}): super(action: action);
}

class VeryLightActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('very_light_activity');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('very_light_activity_explanation');
  @override
  double? physicalActivityFactor = 1.45;
  @override
  Function? action;

  VeryLightActivity({this.action}):
        super(action: action);
}

class LightActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('light_activity');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('light_activity_explanation');
  @override
  double? physicalActivityFactor = 1.65;
  @override
  Function? action;

  LightActivity({this.action}): super(action: action);
}

class ModerateActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('moderated_activity');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('moderated_activity_explanation');
  @override
  double? physicalActivityFactor = 1.85;
  @override
  Function? action;

  ModerateActivity({this.action}): super(action: action);
}

class IntenseActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('intense_activity');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('intense_activity_explanation');
  @override
  double? physicalActivityFactor = 2.25;
  @override
  Function? action;

  IntenseActivity({this.action}):super(action: action);
}

class VeryIntenseActivity extends ActivityByOccupationType {
  @override
  String? typeName = AppLocalizationsHelper.instance.translate('very_intense_activity');
  @override
  String? explanation = AppLocalizationsHelper.instance.translate('very_intense_activity_explanation');
  @override
  double? physicalActivityFactor = 2.5;
  @override
  Function? action;

  VeryIntenseActivity({this.action}):
        super(action: action);
}