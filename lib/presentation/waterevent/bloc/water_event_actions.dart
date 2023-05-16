class WaterEventActions {
  WaterEventActions();
}

class InitializeStateAction extends WaterEventActions {
  InitializeStateAction();
}

class ChooseWaterQuantityAction extends WaterEventActions {
  double qty;

  ChooseWaterQuantityAction({required this.qty});
}

class FinishWaterEventAction extends WaterEventActions {
  final Function onFinish;

  FinishWaterEventAction({required this.onFinish});
}

class ResetStateAction extends WaterEventActions {
  ResetStateAction();
}