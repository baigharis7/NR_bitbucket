import 'package:nutrenaissance_flutter/data/api/sportevents/model/sport_event_response.dart';
import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';

class SportEventsRepositoryImpl extends SportEventsRepository {
  final SportEventsApi sportEventsApi;
  final LocalStorageRepository localStorageRepository;

  SportEventsRepositoryImpl({required this.sportEventsApi, required this.localStorageRepository});

  @override
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple) async {
    final sportEvent = await sportEventsApi.uploadSportEvent(sportEventSimple);
    final sportEventResponse = SportEventResponse.fromJson(sportEvent);
    final sportEventComplete = mapToSportEventCompleteFromResponse(sportEventResponse);
    return sportEventComplete;
  }

  @override
  Future<void> saveSportEvent(SportEventComplete sportEventComplete, bool isEdit) async {
    final sportEventEntity = mapToSportEventEntity(sportEventComplete);
    return await localStorageRepository.saveSportEvent(sportEventEntity, isEdit);
  }

  @override
  Future<List<SportEventComplete>> getTodaySportEvents() async {
    final sportEvents = await localStorageRepository.getSportsEventsOfToday();
    return sportEvents.map((sport) => mapToSportEventComplete(sport as SportEventEntity)).toList();
  }

  @override
  Future<List<SportEventComplete>> getWeeklySportEvents() async {
    final sportEvents = await localStorageRepository.getWeeklySportEvents();
    return sportEvents.map((sport) => mapToSportEventComplete(sport as SportEventEntity)).toList();
  }

  @override
  Future<List<SportEventComplete>> getAllSportEvents() async {
    final sportEvents = await localStorageRepository.getAllSportEvents();
    return sportEvents.map((entity) => mapToSportEventComplete(entity as SportEventEntity)).toList();
  }

  @override
  Future<int?> getDayCalories() async {
    final todaysSportEvents = await getTodaySportEvents();
    if (todaysSportEvents.isEmpty) {
      return 0;
    } else {
      return todaysSportEvents
          .map((sportEventComplete) => sportEventComplete.info.kcal)
          .reduce((value, element) => value.orZero() + element.orZero());
    }
  }

}