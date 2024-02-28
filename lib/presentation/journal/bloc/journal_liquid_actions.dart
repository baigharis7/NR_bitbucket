import '../../../domain/models/liquidevents/liquid_event_complete.dart';

class JournalLiquidActions {
  JournalLiquidActions();
}

class InitializeStateAction extends JournalLiquidActions {
  InitializeStateAction();
}

class HideExplainingCardAction extends JournalLiquidActions {
  HideExplainingCardAction();
}

class DeleteLiquidEventAction extends JournalLiquidActions {
  final LiquidEventComplete liquidEventComplete;
  final Function onFinish;

  DeleteLiquidEventAction({required this.liquidEventComplete, required this.onFinish});
}