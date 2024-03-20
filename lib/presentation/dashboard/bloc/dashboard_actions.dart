import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:pedometer/pedometer.dart';

class DashboardActions {
  DashboardActions();
}

class InitializeState extends DashboardActions {
  InitializeState();
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

class UploadStepsEventAction extends DashboardActions {
  final StepCount stepCount;

  UploadStepsEventAction({required this.stepCount});
}

class UploadCreatineEventAction extends DashboardActions {
  final int value;

  UploadCreatineEventAction({required this.value});
}
