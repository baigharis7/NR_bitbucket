import 'package:nutrenaissance_flutter/data/api/eventssync/events_sync_api.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/model/events_synchronization_request.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/model/events_synchronization_response.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/liquid_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/recipes_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

import '../../../infrastructure/mappers/feces_urine_mappers.dart';
import '../../../infrastructure/mappers/sport_routine_mappers.dart';
import '../../../infrastructure/mappers/supplement_mappers.dart';

class EventsSynchronizationRequestRepositoryImpl extends EventsSynchronizationRequestRepository {
  final LocalStorageRepository localStorageRepository;
  final EventsSyncApi eventsSyncApi;
  final PreferencesRepository preferencesRepository;

  EventsSynchronizationRequestRepositoryImpl({
    required this.localStorageRepository,
    required this.eventsSyncApi,
    required this.preferencesRepository,
  });

  /// List of all categories
  static const List<String> _categories = [
    'foodEvents',
    'foodRoutines',
    'sportEvents',
    'sportRoutines',
    'liquidEvents',
    'waterEvents',
    'foodFavorites',
    'sportFavorites',
    'liquidFavorites',
    'subjectiveAnalysis',
    'recipeFavorites',
    'fecesEvents',
    'urineEvents',
    'creatineEvents',
    'collagenEvents',
    'supplementEvents',
    'supplementFavorites',
    'supplementRoutines',
  ];


  @override
  Future<bool> synchronizeEvents(String userId, {required bool fullSync, bool forceSync = false}) async {
    try {
      if (!forceSync) {
        final syncTime = await preferencesRepository.getLastFetchTime(PrefsKeys.synchronizeEvents);
        if (!_isExpired(syncTime, const Duration(minutes: 10))) return false;
      }

      final idsToSkip = fullSync
          ? _emptyEventsPayload()
          : await _buildEventsPayloadFromLocal();

      final response = await eventsSyncApi.syncAllData(
        userId.orEmpty(),
        idsToSkip,
      );

      final eventsSyncResponse = EventsSynchronizationResponse.fromJson(response);
      await preferencesRepository.saveLastFetchTime(PrefsKeys.synchronizeEvents, DateTime.now());
      return await _saveSynchronizedEvents(eventsSyncResponse);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> fetchEvents(String userId, PrefsKeys categoryType, {required bool fullSync}) async {
    try {
      final lastEventTime = await preferencesRepository.getLastFetchTime(categoryType);
      final syncTime = await preferencesRepository.getLastFetchTime(PrefsKeys.synchronizeEvents);
      final shouldCall = _shouldCallAPI(lastEventTime, syncTime, const Duration(minutes: 10));
      if (!shouldCall) return false;

      final eventsIds = await localStorageRepository.getAllEventIdsByType(categoryType.name);

      // Get the list for the selected category
      final idsToSkip = fullSync
          ? <String>[] // full sync: empty list
          : eventsIds.map((e) => e.toString()).toList();

      final response = await eventsSyncApi.syncCategory(
        userId.orEmpty(),
        categoryType.name,
        idsToSkip,
      );

      final eventsSyncResponse = EventsSynchronizationResponse.fromJson(response);
      await preferencesRepository.saveLastFetchTime(categoryType, DateTime.now());
      return await _saveSynchronizedEvents(eventsSyncResponse);
    } catch (error) {
      rethrow;
    }
  }

  /// Helper to generate empty payload for full sync
  Map<String, List<String>> _emptyEventsPayload() {
    return {for (var category in _categories) category: []};
  }

  /// Helper to build payload from local storage
  Future<Map<String, List<String>>> _buildEventsPayloadFromLocal() async {
    final allEventsIds = await localStorageRepository.getAllEventIds();

    return {
      'foodEvents': allEventsIds.foodEvents.map((e) => e.toString()).toList(),
      'foodRoutines': allEventsIds.foodRoutines.map((e) => e.toString()).toList(),
      'sportEvents': allEventsIds.sportEvents.map((e) => e.toString()).toList(),
      'sportRoutines': allEventsIds.sportRoutines.map((e) => e.toString()).toList(),
      'liquidEvents': allEventsIds.liquidEvents.map((e) => e.toString()).toList(),
      'waterEvents': allEventsIds.waterEvents.map((e) => e.toString()).toList(),
      'foodFavorites': allEventsIds.foodFavorites.map((e) => e.toString()).toList(),
      'sportFavorites': allEventsIds.sportFavorites.map((e) => e.toString()).toList(),
      'liquidFavorites': allEventsIds.liquidFavorites.map((e) => e.toString()).toList(),
      'subjectiveAnalysis': allEventsIds.subjectiveAnalysis.map((e) => e.toString()).toList(),
      'recipeFavorites': allEventsIds.recipeFavorites.map((e) => e.toString()).toList(),
      'fecesEvents': allEventsIds.fecesEvents.map((e) => e.toString()).toList(),
      'urineEvents': allEventsIds.urineEvents.map((e) => e.toString()).toList(),
      'creatineEvents': allEventsIds.creatineEvents.map((e) => e.toString()).toList(),
      'collagenEvents': allEventsIds.collagenEvents.map((e) => e.toString()).toList(),
      'supplementEvents': allEventsIds.supplementEvents.map((e) => e.toString()).toList(),
      'supplementFavorites': allEventsIds.supplementFavorites.map((e) => e.toString()).toList(),
      'supplementRoutines': allEventsIds.supplementRoutines.map((e) => e.toString()).toList(),
    };
  }

  Future<bool> _saveSynchronizedEvents(EventsSynchronizationResponse eventsSynchronizationResponse) async {
    final Set<DataChangedCategory> changedCategories = {};

    if (eventsSynchronizationResponse.foodEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.food);
      for (var foodEvent in eventsSynchronizationResponse.foodEvents) {
        await localStorageRepository.saveFoodEvent(mapToFoodEventEntity(foodEvent), false);
      }
    }

    if (eventsSynchronizationResponse.foodRoutines.isNotEmpty) {
      changedCategories.add(DataChangedCategory.food);
      for (var foodRoutine in eventsSynchronizationResponse.foodRoutines) {
        await localStorageRepository.saveFoodRoutine(mapToFoodRoutineEntity(foodRoutine), isEdit: false);
      }
    }

    if (eventsSynchronizationResponse.sportEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.sport);
      for (var sportEvent in eventsSynchronizationResponse.sportEvents) {
        await localStorageRepository.saveSportEvent(mapToSportEventEntity(sportEvent), false);
      }
    }
    if (eventsSynchronizationResponse.sportRoutines.isNotEmpty) {
      changedCategories.add(DataChangedCategory.sport);
      for (var sportRoutine in eventsSynchronizationResponse.sportRoutines) {
        await localStorageRepository.saveSportRoutine(mapToSportRoutineEntity(sportRoutine), isEdit: false);
      }
    }
    if (eventsSynchronizationResponse.liquidEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.liquid);
      for (var liquidEvent in eventsSynchronizationResponse.liquidEvents) {
        await localStorageRepository.saveLiquidEvent(mapToLiquidEventEntity(liquidEvent), false);
      }
    }
    if (eventsSynchronizationResponse.waterEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.water);
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
      changedCategories.add(DataChangedCategory.fecesUrine);
      for (var uploadFecesEvent in eventsSynchronizationResponse.fecesEvents) {
        await localStorageRepository.saveFecesEvent(mapToUploadFecesEventEntity(uploadFecesEvent));
      }
    }
    if (eventsSynchronizationResponse.urineEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.fecesUrine);
      for (var uploadUrineEvent in eventsSynchronizationResponse.urineEvents) {
        await localStorageRepository.saveUrineEvent(mapToUploadFecesEventEntity(uploadUrineEvent));
      }
    }

    if (eventsSynchronizationResponse.creatineEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.supplement);
      for (var uploadCreatineEvent in eventsSynchronizationResponse.creatineEvents) {
        await localStorageRepository.saveCreatineEvent(mapToSupplementEventEntity(uploadCreatineEvent));
      }
    }

    if (eventsSynchronizationResponse.collagenEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.supplement);
      for (var uploadCollagenEvent in eventsSynchronizationResponse.collagenEvents) {
        await localStorageRepository.saveCollagenEvent(mapToSupplementEventEntity(uploadCollagenEvent));
      }
    }

    if (eventsSynchronizationResponse.supplementEvents.isNotEmpty) {
      changedCategories.add(DataChangedCategory.supplement);
      for (var supplementEvent in eventsSynchronizationResponse.supplementEvents) {
        await localStorageRepository.saveSupplementEvent(mapToSupplementEventsEntity(supplementEvent));
      }
    }

    if (eventsSynchronizationResponse.supplementFavorites.isNotEmpty) {
      for (var supplementFavorite in eventsSynchronizationResponse.supplementFavorites) {
        await localStorageRepository.saveSupplementFavorite(mapToSupplementEventEntityFromFavorite(supplementFavorite));
      }
    }

    if (eventsSynchronizationResponse.supplementRoutines.isNotEmpty) {
      changedCategories.add(DataChangedCategory.supplement);
      for (var supplementRoutine in eventsSynchronizationResponse.supplementRoutines) {
        await localStorageRepository.saveSupplementRoutine(mapToSupplementEventEntityFromRoutine(supplementRoutine));
      }
    }

    // Notify DashboardEventBus for each category that received new data
    for (final category in changedCategories) {
      DashboardEventBus.instance.notify(category);
    }

    return changedCategories.isNotEmpty;
  }

  bool _shouldCallAPI(DateTime? lastTime, DateTime? syncTime, Duration threshold) {
    return _isExpired(lastTime, threshold) && _isExpired(syncTime, threshold);
  }

  bool _isExpired(DateTime? time, Duration threshold) {
    if (time == null) return true;
    final now = DateTime.now();
    return now.isAfter(time.add(threshold));
  }

}