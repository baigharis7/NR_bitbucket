import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/delete_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class DeleteLiquidEventInteractorImpl extends DeleteLiquidEventInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  DeleteLiquidEventInteractorImpl({required this.liquidEventsRepository});

  @override
  Future<void> execute(String userId, int eventDate) => liquidEventsRepository.deleteLiquidEvent(userId, eventDate);

}