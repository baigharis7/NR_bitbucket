import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class SaveLiquidEventInteractorImpl extends SaveLiquidEventInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  SaveLiquidEventInteractorImpl({required this.liquidEventsRepository});

  @override
  Future<void> execute(UploadLiquidEvent uploadLiquidEvent, bool isEdit) => liquidEventsRepository.saveLiquidEvent(uploadLiquidEvent, isEdit);

}