import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';

abstract class RemoveLiquidEventInteractor {
  Future<void> execute(LiquidEventComplete liquidEventComplete);
}