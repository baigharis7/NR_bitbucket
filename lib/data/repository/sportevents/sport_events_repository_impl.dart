import 'package:nutrenaissance_flutter/data/api/sportevents/sport_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sport_kcal_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class SportEventsRepositoryImpl extends SportEventsRepository {
  final SportEventsApi sportEventsApi;
  final LocalStorageRepository localStorageRepository;
  final SportKcalCalculationService sportKcalCalculationService;
  final SyncQueueService syncQueue;

  SportEventsRepositoryImpl({
    required this.sportEventsApi,
    required this.localStorageRepository,
    required this.sportKcalCalculationService,
    required this.syncQueue,
  });

  @override
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple) async {
    // Get user weight from local profile
    final profile = await localStorageRepository.getProfile();
    final userWeight = profile?.physicalCharacteristics?.weight ?? 70.0;

    // Compute kcal locally (replaces blocking Lambda call)
    final sportEventComplete = await sportKcalCalculationService.enrichSportEvent(
      sportEventSimple,
      userWeight: userWeight,
    );

    // Fire background API call for DynamoDB persistence (don't block UI)
    syncToBackend(sportEventComplete);

    return sportEventComplete;
  }

  @override
  void syncToBackend(SportEventComplete sportEventComplete) {
    sportEventsApi.saveSportEvent(sportEventComplete).catchError((error) {
      syncQueue.enqueue('/sport-event', sportEventComplete);
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> saveSportEvent(SportEventComplete sportEventComplete, bool isEdit) async {
    final sportEventEntity = mapToSportEventEntity(sportEventComplete);
    return await localStorageRepository.saveSportEvent(sportEventEntity, isEdit);
  }

  @override
  Future<List<SportEventComplete>> getTodaySportEvents({DateTime? dateTime}) async {
    final sportEvents = await localStorageRepository.getSportsEventsOfToday(dateTime: dateTime);
    final events = sportEvents.map((sport) => mapToSportEventComplete(sport as SportEventEntity)).toList();
    events.sort((a, b) => a.eventId.compareTo(b.eventId));
    return events;
  }

  @override
  Future<List<SportEventComplete>> getWeeklySportEvents() async {
    final sportEvents = await localStorageRepository.getWeeklySportEvents();
    return sportEvents.map((sport) => mapToSportEventComplete(sport as SportEventEntity)).toList();
  }

  @override
  Future<List<SportEventComplete>> getRecentSportEvents() async {
    final sportEvents = await localStorageRepository.getRecentSportEvents();
    return sportEvents.map((sport) => mapToSportEventComplete(sport as SportEventEntity)).toList();
  }

  @override
  Future<List<SportEventComplete>> getAllSportEvents() async {
    final sportEvents = await localStorageRepository.getAllSportEvents();
    return sportEvents.map((entity) => mapToSportEventComplete(entity as SportEventEntity)).toList();
  }

  @override
  Future<int?> getDayCalories({DateTime? dateTime}) async {
    final todaysSportEvents = await getTodaySportEvents(dateTime: dateTime);
    if (todaysSportEvents.isEmpty) {
      return 0;
    } else {
      return todaysSportEvents
          .map((sportEventComplete) => sportEventComplete.eventKcals)
          .reduce((value, element) => value.orZero() + element.orZero());
    }
  }

  @override
  Future<void> removeSportEvent(SportEventComplete sportEventComplete) async {
    try {
      await localStorageRepository.removeSportEvent(sportEventComplete);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSportEvent(String userId, int eventId) async {
    sportEventsApi.deleteSportEvent(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/sport-event', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
  }
}
