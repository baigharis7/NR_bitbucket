import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class UploadLiquidEventInteractorImpl extends UploadLiquidEventInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  UploadLiquidEventInteractorImpl({required this.liquidEventsRepository});

  @override
  Future<UploadLiquidEvent> execute(LiquidEventSimple liquidEventSimple) async {
    return liquidEventsRepository.uploadLiquidEvent(liquidEventSimple);
  }

}
