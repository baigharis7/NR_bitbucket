import 'package:flutter/material.dart';

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


