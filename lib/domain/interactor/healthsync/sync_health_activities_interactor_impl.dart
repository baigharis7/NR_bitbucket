import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/health_activity_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_activity_type_mapping.dart';

class SyncHealthActivitiesInteractorImpl implements SyncHealthActivitiesInteractor {
  final HealthSyncRepository healthSyncRepository;
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;
  final UploadSportEventsInteractor uploadSportEventsInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;

  /// Minimum time between syncs (15 minutes)
  static const Duration _minSyncInterval = Duration(minutes: 15);

  /// Default lookback period for first sync (7 days)
  static const Duration _defaultLookback = Duration(days: 7);

  SyncHealthActivitiesInteractorImpl({
    required this.healthSyncRepository,
    required this.localStorageRepository,
    required this.preferencesRepository,
    required this.uploadSportEventsInteractor,
    required this.saveSportEventInteractor,
  });

  @override
  Future<List<SportEventComplete>> execute({DateTime? since}) async {
    final syncedEvents = <SportEventComplete>[];

    try {
      // Check if sync is enabled
      final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
      if (!isEnabled) return syncedEvents;

      // Check if we have permissions
      final hasPermissions = await healthSyncRepository.hasPermissions();
      if (!hasPermissions) return syncedEvents;

      // Check throttling - don't sync if we synced recently
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();
      if (since == null && lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
        if (timeSinceLastSync < _minSyncInterval) {
          return syncedEvents;
        }
      }

      // Determine sync start time
      final DateTime startDate;
      if (since != null) {
        startDate = since;
      } else if (lastSyncTime != null) {
        startDate = lastSyncTime;
      } else {
        // First sync - go back 7 days
        startDate = DateTime.now().subtract(_defaultLookback);
      }
      final endDate = DateTime.now();

      // Get user ID
      final userId = preferencesRepository.getSub();
      if (userId.isEmpty) return syncedEvents;

      // Get sports master file for mapping
      final sportsInfo = await localStorageRepository.getMasterFile(
        MasterFilesType.sportsInfo,
      ) as SportsInfoEntity?;
      if (sportsInfo == null) return syncedEvents;

      // Fetch activities from health platform
      final activities = await healthSyncRepository.fetchActivities(
        startDate: startDate,
        endDate: endDate,
      );

      // Fetch steps as well
      final steps = await healthSyncRepository.fetchSteps(
        startDate: startDate,
        endDate: endDate,
      );

      // Combine and deduplicate
      final allActivities = [...activities, ...steps];
      final newActivities = await _deduplicateActivities(allActivities);

      // Process each new activity
      for (final activity in newActivities) {
        try {
          final sportEvent = await _processActivity(
            activity,
            userId,
            sportsInfo,
          );
          if (sportEvent != null) {
            syncedEvents.add(sportEvent);
          }
        } catch (e) {
          // Log error but continue with other activities
          continue;
        }
      }

      // Update last sync time
      await healthSyncRepository.setLastSyncTime(DateTime.now());

      return syncedEvents;
    } catch (e) {
      return syncedEvents;
    }
  }

  /// Filter out activities that have already been synced
  Future<List<HealthActivity>> _deduplicateActivities(
    List<HealthActivity> activities,
  ) async {
    final newActivities = <HealthActivity>[];
    for (final activity in activities) {
      final alreadySynced = await healthSyncRepository.isAlreadySynced(
        activity.healthPlatformId,
      );
      if (!alreadySynced) {
        newActivities.add(activity);
      }
    }
    return newActivities;
  }

  /// Process a single health activity: map to sport event, upload, save locally
  Future<SportEventComplete?> _processActivity(
    HealthActivity activity,
    String userId,
    SportsInfoEntity sportsInfo,
  ) async {
    // Find matching sport ID
    int? sportId = HealthActivityTypeMapping.mapToSportId(
      activity.activityType,
      sportsInfo,
    );
    sportId ??= HealthActivityTypeMapping.findFallbackSportId(sportsInfo);
    if (sportId == null) return null;

    // Create sport event simple for upload
    final sportEventSimple = mapHealthActivityToSportEventSimple(
      activity: activity,
      userId: userId,
      sportId: sportId,
      sportsInfo: sportsInfo,
    );

    // Upload to AWS backend
    final uploadedEvent = await uploadSportEventsInteractor.execute(sportEventSimple);

    // Save locally
    await saveSportEventInteractor.execute(uploadedEvent, false);

    // Save sync metadata for deduplication
    final metadata = HealthSyncMetadata(
      healthPlatformId: activity.healthPlatformId,
      sportEventId: uploadedEvent.eventId,
      syncedAt: DateTime.now(),
      sourceType: activity.sourceType,
    );
    await healthSyncRepository.saveHealthSyncMetadata(metadata);

    return uploadedEvent;
  }
}
