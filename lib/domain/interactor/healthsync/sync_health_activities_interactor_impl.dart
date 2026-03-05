import 'package:flutter/foundation.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/health_activity_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_activity_type_mapping.dart';

class SyncHealthActivitiesInteractorImpl implements SyncHealthActivitiesInteractor {
  final HealthSyncRepository healthSyncRepository;
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;
  final SaveSportEventInteractor saveSportEventInteractor;
  final SportEventsRepository sportEventsRepository;

  /// Minimum time between automatic syncs (5 minutes)
  static const Duration _minSyncInterval = Duration(minutes: 5);

  /// Default lookback period for first sync (7 days)
  static const Duration _defaultLookback = Duration(days: 7);

  static void _log(String message) {
    debugPrint('[HealthSync] $message');
    CrashlyticsService.instance.log(message);
  }

  SyncHealthActivitiesInteractorImpl({
    required this.healthSyncRepository,
    required this.localStorageRepository,
    required this.preferencesRepository,
    required this.saveSportEventInteractor,
    required this.sportEventsRepository,
  });

  @override
  Future<List<SportEventComplete>> execute({DateTime? since}) async {
    final syncedEvents = <SportEventComplete>[];

    try {
      // Check if sync is enabled
      final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
      if (!isEnabled) {
        _log('Sync aborted: sync not enabled');
        return syncedEvents;
      }

      // Check if we have permissions
      final hasPermissions = await healthSyncRepository.hasPermissions();
      if (!hasPermissions) {
        _log('Sync aborted: no permissions');
        return syncedEvents;
      }

      // Check throttling - don't sync if we synced recently
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();
      if (since == null && lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
        if (timeSinceLastSync < _minSyncInterval) {
          _log('Sync throttled: last sync ${timeSinceLastSync.inMinutes}m ago');
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
      _log('Sync window: $startDate → $endDate');

      // Get user ID
      final userId = preferencesRepository.getSub();
      if (userId.isEmpty) {
        _log('Sync aborted: empty userId');
        return syncedEvents;
      }

      // Get sports master file for mapping
      final sportsInfo = await localStorageRepository.getMasterFile(
        MasterFilesType.sportsInfo,
      ) as SportsInfoEntity?;
      if (sportsInfo == null) {
        _log('Sync aborted: sportsInfo master file not loaded');
        return syncedEvents;
      }

      // Fetch activities from health platform
      final activities = await healthSyncRepository.fetchActivities(
        startDate: startDate,
        endDate: endDate,
      );
      _log('Fetched ${activities.length} activities from health platform');

      // Fetch steps as well
      final steps = await healthSyncRepository.fetchSteps(
        startDate: startDate,
        endDate: endDate,
      );
      _log('Fetched ${steps.length} step entries from health platform');

      // Combine and deduplicate
      final allActivities = [...activities, ...steps];
      final newActivities = await _deduplicateActivities(allActivities);
      _log('After dedup: ${newActivities.length} new activities (${allActivities.length - newActivities.length} already synced)');

      // Process each new activity
      for (final activity in newActivities) {
        try {
          final sportEvent = await _processActivity(
            activity,
            userId,
            sportsInfo,
          );
          if (sportEvent != null) {
            _log('Synced: ${activity.activityType} (${activity.healthPlatformId}) → ${sportEvent.sportName}');
            syncedEvents.add(sportEvent);
          } else {
            _log('Skipped: ${activity.activityType} — no matching sportId');
          }
        } catch (e) {
          _log('Error processing ${activity.activityType}: $e');
          continue;
        }
      }

      // Update last sync time
      await healthSyncRepository.setLastSyncTime(DateTime.now());
      _log('Sync complete: ${syncedEvents.length} activities saved');

      return syncedEvents;
    } catch (e, stack) {
      _log('Sync failed with error: $e');
      CrashlyticsService.record(e, stack, context: {'event': 'SyncHealthActivities'});
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

  /// Process a single health activity: build sport event with health platform
  /// calories (no METs recalculation), save locally, sync to backend.
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

    // Build SportEventComplete directly with health platform calories
    // (skips SportKcalCalculationService — health platform data is more accurate)
    final sportEvent = mapHealthActivityToSportEventComplete(
      activity: activity,
      userId: userId,
      eventId: activity.startTime.millisecondsSinceEpoch,
      sportId: sportId,
      sportsInfo: sportsInfo,
      eventKcals: activity.caloriesBurned?.round() ?? 0,
    );

    // Save locally
    await saveSportEventInteractor.execute(sportEvent, false);

    // Sync to DynamoDB (fire-and-forget, same as manual entry)
    sportEventsRepository.syncToBackend(sportEvent);

    // Save sync metadata for deduplication
    final metadata = HealthSyncMetadata(
      healthPlatformId: activity.healthPlatformId,
      sportEventId: sportEvent.eventId,
      syncedAt: DateTime.now(),
      sourceType: activity.sourceType,
    );
    await healthSyncRepository.saveHealthSyncMetadata(metadata);

    return sportEvent;
  }
}
