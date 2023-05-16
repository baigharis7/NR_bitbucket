import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';

class GetTodayLiquidEventsInteractorImpl extends GetTodayLiquidEventsInteractor {
  final LiquidEventsRepository liquidEventsRepository;

  GetTodayLiquidEventsInteractorImpl({
    required this.liquidEventsRepository,
  });

  @override
  Future<List<LiquidEventComplete>> execute() async => await liquidEventsRepository.getTodayLiquidEvents();

}
