import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';

abstract class SaveLiquidEventInteractor {
  Future<void> execute(UploadLiquidEvent uploadLiquidEvent, bool isEdit);
}