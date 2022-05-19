// ignore_for_file: overridden_fields
import 'dart:core';

import '../../../infrastructure/helpers/i10n_helper.dart';

class ActivityByOccupationType {
  String? typeName;
  String? explanation;
  double? physicalActivityFactor;
  Function? action;

  static List<ActivityByOccupationType> listAllActivityTypes() {
    return [
      ReposeActivity(typeName: AppLocalizations.instance.translate('repose'),
        explanation: AppLocalizations.instance.translate('repose_explanation'),),
      VeryLightActivity(
          typeName: AppLocalizations.instance.translate('very_light_activity'),
          explanation: AppLocalizations.instance.translate('very_light_activity_explanation')),
      LightActivity(typeName: AppLocalizations.instance.translate('light_activity'),
          explanation: AppLocalizations.instance.translate('light_activity_explanation')),
      ModerateActivity(
        typeName: AppLocalizations.instance.translate('moderated_activity'),
        explanation: AppLocalizations.instance.translate('moderated_activity_explanation'),),
      IntenseActivity(
        typeName: AppLocalizations.instance.translate('intense_activity'),
        explanation: AppLocalizations.instance.translate('intense_activity_explanation'),),
      VeryIntenseActivity(
        typeName: AppLocalizations.instance.translate('very_intense_activity'),
        explanation: AppLocalizations.instance.translate('very_intense_activity_explanation'),),
    ];
  }
  ActivityByOccupationType({this.typeName, required this.explanation, this.physicalActivityFactor, this.action});
}

class ReposeActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 1.2;
  @override
  Function? action;

  ReposeActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}

class VeryLightActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 1.45;
  @override
  Function? action;

  VeryLightActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}

class LightActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 1.65;
  @override
  Function? action;

  LightActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}

class ModerateActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 1.85;
  @override
  Function? action;

  ModerateActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}

class IntenseActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 2.25;
  @override
  Function? action;

  IntenseActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}

class VeryIntenseActivity extends ActivityByOccupationType {
  @override
  String? typeName;
  @override
  String? explanation;
  @override
  double? physicalActivityFactor = 2.5;
  @override
  Function? action;

  VeryIntenseActivity({required this.typeName, required this.explanation, this.action}):
        super(typeName: typeName, explanation: explanation, action: action);
}