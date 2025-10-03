import 'package:nutrenaissance_flutter/data/api/eventssync/events_sync_api.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/model/events_synchronization_response.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/liquid_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/recipes_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';

import '../../../infrastructure/mappers/feces_urine_mappers.dart';
import '../../../infrastructure/mappers/sport_routine_mappers.dart';
import '../../../infrastructure/mappers/supplement_mappers.dart';

class EventsSynchronizationRequestRepositoryImpl extends EventsSynchronizationRequestRepository {
  final LocalStorageRepository localStorageRepository;
  final EventsSyncApi eventsSyncApi;

  EventsSynchronizationRequestRepositoryImpl({
    required this.localStorageRepository,
    required this.eventsSyncApi,
  });

  @override
  Future<bool> synchronizeEvents(String userId) async {
    final allEventsIds = await localStorageRepository.getAllEventIds();
    try {
      final response = await eventsSyncApi.sendEventsIds(
        userId.orEmpty(),
        /*allEventsIds.foodEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.sportEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.sportRoutines.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.liquidEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.waterEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.foodFavorites.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.sportFavorites.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.liquidFavorites.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.subjectiveAnalysis.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.recipeFavorites.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.fecesEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.urineEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.creatineEvents.map((e) => e.toString()).toList()*/ [],
        /*allEventsIds.collagenEvents.map((e) => e.toString()).toList()*/ [],
        [],
        /*allEventsIds.supplementEvents.map((e) => e.toString()).toList()*/ [],
      );
      final eventsSyncResponse = EventsSynchronizationResponse.fromJson(response);
      return await _saveSynchronizedEvents(eventsSyncResponse).then((value) => value);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> _saveSynchronizedEvents(EventsSynchronizationResponse eventsSynchronizationResponse) async {
    if (eventsSynchronizationResponse.foodEvents.isNotEmpty) {
      for (var foodEvent in eventsSynchronizationResponse.foodEvents) {
        await localStorageRepository.saveFoodEvent(mapToFoodEventEntity(foodEvent), false);
      }
    }

    if (eventsSynchronizationResponse.foodRoutines.isNotEmpty) {
      for (var foodRoutine in eventsSynchronizationResponse.foodRoutines) {
        await localStorageRepository.saveFoodRoutine(mapToFoodRoutineEntity(foodRoutine), isEdit: false);
      }
    }

    if (eventsSynchronizationResponse.sportEvents.isNotEmpty) {
      for (var sportEvent in eventsSynchronizationResponse.sportEvents) {
        await localStorageRepository.saveSportEvent(mapToSportEventEntity(sportEvent), false);
      }
    }
    if (eventsSynchronizationResponse.sportRoutines.isNotEmpty) {
      for (var sportRoutine in eventsSynchronizationResponse.sportRoutines) {
        await localStorageRepository.saveSportRoutine(mapToSportRoutineEntity(sportRoutine), isEdit: false);
      }
    }
    if (eventsSynchronizationResponse.liquidEvents.isNotEmpty) {
      for (var liquidEvent in eventsSynchronizationResponse.liquidEvents) {
        await localStorageRepository.saveLiquidEvent(mapToLiquidEventEntity(liquidEvent), false);
      }
    }
    if (eventsSynchronizationResponse.waterEvents.isNotEmpty) {
      for (var waterEvent in eventsSynchronizationResponse.waterEvents) {
        await localStorageRepository.saveWaterEvent(waterEvent);
      }
    }
    if (eventsSynchronizationResponse.foodFavorites.isNotEmpty) {
      for (var foodFavorite in eventsSynchronizationResponse.foodFavorites) {
        await localStorageRepository.saveFoodFavorite(foodFavorite);
      }
    }
    if (eventsSynchronizationResponse.sportFavorites.isNotEmpty) {
      for (var sportFavorite in eventsSynchronizationResponse.sportFavorites) {
        await localStorageRepository.saveSportFavorite(sportFavorite);
      }
    }
    if (eventsSynchronizationResponse.liquidFavorites.isNotEmpty) {
      for (var liquidFavorite in eventsSynchronizationResponse.liquidFavorites) {
        await localStorageRepository.saveLiquidFavorite(liquidFavorite);
      }
    }
    if (eventsSynchronizationResponse.subjectiveAnalysis.isNotEmpty) {
      for (var subjectiveAnalysis in eventsSynchronizationResponse.subjectiveAnalysis) {
        await localStorageRepository.saveSubjectiveAnalysis(subjectiveAnalysis);
      }
    }
    if (eventsSynchronizationResponse.recipeFavorites.isNotEmpty) {
      for (var uploadRecipeFavorite in eventsSynchronizationResponse.recipeFavorites) {
        await localStorageRepository.saveRecipeFavorite(mapToRecipeFavoriteEntity(uploadRecipeFavorite));
      }
    }
    if (eventsSynchronizationResponse.fecesEvents.isNotEmpty) {
      for (var uploadFecesEvent in eventsSynchronizationResponse.fecesEvents) {
        await localStorageRepository.saveFecesEvent(mapToUploadFecesEventEntity(uploadFecesEvent));
      }
    }
    if (eventsSynchronizationResponse.urineEvents.isNotEmpty) {
      for (var uploadUrineEvent in eventsSynchronizationResponse.urineEvents) {
        await localStorageRepository.saveUrineEvent(mapToUploadFecesEventEntity(uploadUrineEvent));
      }
    }

    if (eventsSynchronizationResponse.creatineEvents.isNotEmpty) {
      for (var uploadCreatineEvent in eventsSynchronizationResponse.creatineEvents) {
        await localStorageRepository.saveCreatineEvent(mapToSupplementEventEntity(uploadCreatineEvent));
      }
    }

    if (eventsSynchronizationResponse.collagenEvents.isNotEmpty) {
      for (var uploadCollagenEvent in eventsSynchronizationResponse.collagenEvents) {
        await localStorageRepository.saveCollagenEvent(mapToSupplementEventEntity(uploadCollagenEvent));
      }
    }

    if (eventsSynchronizationResponse.supplementEvents.isNotEmpty) {
      for (var supplementEvent in eventsSynchronizationResponse.supplementEvents) {
        await localStorageRepository.saveSupplementEvent(mapToSupplementEventsEntity(supplementEvent));
      }
    }

    return true;
  }

}