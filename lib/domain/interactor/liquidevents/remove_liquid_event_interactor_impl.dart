import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/remove_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class RemoveLiquidEventInteractorImpl extends RemoveLiquidEventInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  RemoveLiquidEventInteractorImpl({required this.liquidEventsRepository});

  @override
  Future<void> execute(LiquidEventComplete liquidEventComplete) => liquidEventsRepository.removeLiquidEvent(liquidEventComplete);
}