import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/lists/SupplementInfo.dart';

class DashboardActions {
  DashboardActions();
}

class InitializeState extends DashboardActions {
  final DateTime? dateTime;
  final Function? onFinish;

  InitializeState({this.dateTime, this.onFinish});
}

class HideCardAction extends DashboardActions {
  HideCardAction();
}

class GetFoodEventsAction extends DashboardActions {
  GetFoodEventsAction();
}

class GetNutrientNameAction extends DashboardActions {
  String nutrientName;
  BuildContext context;

  GetNutrientNameAction({
    required this.nutrientName,
    required this.context,
  });
}

class ReloadWaterInfoAction extends DashboardActions {
  ReloadWaterInfoAction();
}

class UpdateMenstruationStateAction extends DashboardActions {
  final bool isMenstruation;

  UpdateMenstruationStateAction({required this.isMenstruation});
}

class UpdateColdStateAction extends DashboardActions {
  final bool isCold;

  UpdateColdStateAction({required this.isCold});
}

class UpdateProfileEventAction extends DashboardActions {
  final bool value;

  UpdateProfileEventAction({required this.value});
}

class FinishWaterEventAction extends DashboardActions {
  double qty;
  final Function onFinish;

  FinishWaterEventAction({required this.qty, required this.onFinish});
}

class UploadCreatineEventAction extends DashboardActions {
  final SupplementInfo? supplementInfo;
  final int value;

  UploadCreatineEventAction({required this.supplementInfo, required this.value});
}

class UploadCollagenEventAction extends DashboardActions {
  final SupplementInfo? supplementInfo;
  final int value;

  UploadCollagenEventAction({required this.supplementInfo, required this.value});
}

class LogoutFromAppEventAction extends DashboardActions {
  final Function onFinish;

  LogoutFromAppEventAction({required this.onFinish});
}

class ShowDialogEventAction extends DashboardActions {}

class ShowLogs extends DashboardActions {}

class SaveHideModelInfo extends DashboardActions {}
