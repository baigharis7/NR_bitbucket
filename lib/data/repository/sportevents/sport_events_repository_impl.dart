import 'package:nutrenaissance_flutter/data/api/sportevents/model/sport_event_response.dart';
import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';

class SportEventsRepositoryImpl extends SportEventsRepository {
  final SportEventsApi sportEventsApi;
  final LocalStorageRepository localStorageRepository;

  SportEventsRepositoryImpl({required this.sportEventsApi, required this.localStorageRepository});

  @override
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple) async {
    final sportEventResponse = SportEventResponse.fromJson(await sportEventsApi.uploadSportEvent(sportEventSimple));
    final sportEventComplete = mapToSportEventCompleteFromResponse(sportEventResponse);
    return sportEventComplete;
  }

  @override
  Future<void> saveSportEvent(SportEventComplete sportEventComplete) async {
    final sportEventEntity = mapToSportEventEntity(sportEventComplete);
    return await localStorageRepository.saveSportEvent(sportEventEntity);
  }
}