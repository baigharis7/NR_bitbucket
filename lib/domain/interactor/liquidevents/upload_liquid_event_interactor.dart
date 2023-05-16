import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';

abstract class UploadLiquidEventInteractor {
  Future<UploadLiquidEvent> execute(LiquidEventSimple liquidEventSimple);
}