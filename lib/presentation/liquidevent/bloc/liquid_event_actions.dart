import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';

class LiquidEventActions {
  LiquidEventActions();
}

class InitializeStateAction extends LiquidEventActions {
  InitializeStateAction();
}

class AddLiquidFromEventAction extends LiquidEventActions {
  final LiquidInEvent liquid;

  AddLiquidFromEventAction({required this.liquid});
}

class RemoveLiquidFromEventAction extends LiquidEventActions {
  final LiquidInEvent liquid;

  RemoveLiquidFromEventAction({required this.liquid});
}

class ReceiveLiquidsInEventFromNavigationAction extends LiquidEventActions {
  final LiquidEventSimple liquidEventSimple;

  ReceiveLiquidsInEventFromNavigationAction({required this.liquidEventSimple});
}

class ResetLiquidEventInfoAction extends LiquidEventActions {
  ResetLiquidEventInfoAction();
}

class ReceiveEventDateAction extends LiquidEventActions {
  final DateTime dateTime;

  ReceiveEventDateAction({required this.dateTime});
}

class FinishLiquidEventAction extends LiquidEventActions {
  Function onFinish;

  FinishLiquidEventAction({required this.onFinish});
}

