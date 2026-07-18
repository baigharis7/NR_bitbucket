import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/health_sync_background_service.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/step_estimation_utils.dart';

part 'health_sync_event.dart';
part 'health_sync_state.dart';

void _hsLog(String message) {
  debugPrint('[HealthSync] $message');
  CrashlyticsService.instance.log(message);
}

class HealthSyncBloc extends Bloc<HealthSyncEvent, HealthSyncState> {
  final HealthSyncRepository healthSyncRepository;
  final CheckHealthSyncStatusInteractor checkHealthSyncStatusInteractor;
  final RequestHealthPermissionsInteractor requestHealthPermissionsInteractor;
  final ToggleHealthSyncInteractor toggleHealthSyncInteractor;
  final SyncHealthActivitiesInteractor syncHealthActivitiesInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;

  static const _periodicSyncInterval = Duration(minutes: 5);
  Timer? _periodicSyncTimer;
  StreamSubscription<DataChangedCategory>? _eventBusSubscription;

  HealthSyncBloc({
    required this.healthSyncRepository,
    required this.checkHealthSyncStatusInteractor,
    required this.requestHealthPermissionsInteractor,
    required this.toggleHealthSyncInteractor,
    required this.syncHealthActivitiesInteractor,
    required this.getTodaySportsInteractor,
    required this.getMasterFileInteractor,
  }) : super(HealthSyncState()) {
    on<HealthSyncInitialization>(_onInitialization);
    on<HealthSyncRequestPermissions>(_onRequestPermissions);
    on<HealthSyncToggle>(_onToggle);
    on<HealthSyncManualTrigger>(_onManualTrigger);
    on<HealthSyncInstallHealthConnect>(_onInstallHealthConnect);
    on<HealthSyncOpenHealthConnect>(_onOpenHealthConnect);
    on<HealthSyncLoadForDate>(_onLoadForDate);
    on<HealthSyncUpdatePermissions>(_onUpdatePermissions);
    on<HealthSyncRecalculateEstimatedSteps>(_onRecalculateEstimatedSteps);

    // Recalculate estimated steps when sport events change.
    _eventBusSubscription = DashboardEventBus.instance.stream
        .where((cat) => cat == DataChangedCategory.sport)
        .listen((_) => add(HealthSyncRecalculateEstimatedSteps()));

    // Load persisted state immediately so the dashboard has correct values.
    add(HealthSyncInitialization());
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (_) {
      _hsLog('HealthSync: periodic sync triggered');
      add(HealthSyncManualTrigger());
    });
    _hsLog('HealthSync: periodic sync timer started (every ${_periodicSyncInterval.inMinutes}m)');
  }

  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _hsLog('HealthSync: periodic sync timer stopped');
  }

  @override
  Future<void> close() {
    _periodicSyncTimer?.cancel();
    _eventBusSubscription?.cancel();
    return super.close();
  }

  /// Fetch sleep/step from Health Connect for a date and save to Hive + DynamoDB.
  /// A null result from a fetch means the call errored — skip the save for
  /// that field so we don't overwrite a previously good value with 0.
  Future<({double? sleepHours, int? stepCount})> _fetchAndSave(DateTime date) async {
    final sleepHours = await healthSyncRepository.fetchTodaySleepHours(date);
    final stepCount = await healthSyncRepository.fetchTodayStepCount(date);
    if (sleepHours != null) {
      await healthSyncRepository.saveSleepEvent(date: date, sleepHours: sleepHours);
    }
    if (stepCount != null) {
      await healthSyncRepository.saveStepEvent(date: date, stepCount: stepCount);
    }
    return (sleepHours: sleepHours, stepCount: stepCount);
  }

  Future<void> _onInitialization(
    HealthSyncInitialization event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
      _hsLog('HealthSync init: isAvailable=$isAvailable');

      final isEnabled = await healthSyncRepository.isHealthSyncEnabled();

      // Only check permissions if HC is available — calling hasPermissions
      // when HC is not installed throws on some devices.
      bool hasPermissions = false;
      if (isAvailable) {
        hasPermissions = await healthSyncRepository.hasPermissions();
      }
      _hsLog('HealthSync init: isEnabled=$isEnabled, hasPermissions=$hasPermissions');

      // Note: We no longer auto-disable sync when permissions are revoked.
      // Instead we fall back to saved data so the dashboard widgets remain
      // visible even if Health Connect temporarily loses permissions.

      final lastSyncTime = await healthSyncRepository.getLastSyncTime();

      // Trust the user's stored preference as source of truth.  On Android,
      // hasPermissions() is unreliable after app restarts and may return
      // false even when permissions are still granted.  Start the periodic
      // sync whenever the user chose to enable sync — data fetches already
      // handle permission failures gracefully by returning empty results.
      if (isEnabled && isAvailable) {
        _startPeriodicSync();
        // Re-register the WorkManager background task in case it was lost
        // after an app update or device restart.  Fire-and-forget — failure
        // here (e.g. missing platform plugin) should not block init.
        HealthSyncBackgroundService.registerPeriodicSync().catchError((e) {
          _hsLog('HealthSync init: background service registration failed: $e');
        });
      } else {
        _stopPeriodicSync();
      }

      final today = DateTime.now();

      // Load previously saved data first (survives sync toggle-off).
      double? sleepHours = await healthSyncRepository.getSavedSleepHours(today);
      int? stepCount = await healthSyncRepository.getSavedStepCount(today);

      // Fetch fresh data from Health Connect if sync is enabled.
      // Even if hasPermissions is false, attempt the fetch — HC may still
      // allow reads and the call fails gracefully with empty results.
      if (isEnabled && isAvailable) {
        try {
          final fresh = await _fetchAndSave(today);
          // Only override saved values when the fetch returned a real reading.
          // A null means the fetch errored — keep the previously saved value.
          if (fresh.sleepHours != null) sleepHours = fresh.sleepHours;
          if (fresh.stepCount != null) stepCount = fresh.stepCount;
          _hsLog('HealthSync init: sleepHours=$sleepHours, stepCount=$stepCount');
        } catch (e) {
          _hsLog('HealthSync init: fetch failed (permissions likely revoked), using saved data');
        }
      }

      // Calculate estimated steps from manual sport events
      final estimatedSteps = await _calculateEstimatedSteps(today);

      emit(state.copyWith(
        isLoading: false,
        isAvailable: isAvailable,
        isSyncEnabled: isEnabled,
        hasPermissions: hasPermissions,
        lastSyncTime: lastSyncTime,
        todaySleepHours: sleepHours,
        todayStepCount: stepCount,
        estimatedStepCount: estimatedSteps,
      ));

      // A false probe alone is not attention-worthy: Health Connect
      // under-reports after restarts and HealthKit cannot report read grants
      // at all. Chain a verification sync instead — its permissionResolution
      // (verified denial vs tolerated false negative) decides whether real
      // permission attention is needed.
      if (isEnabled && isAvailable && !hasPermissions) {
        _hsLog('HealthSync init: probe reported no permissions — '
            'chaining verification sync');
        add(HealthSyncManualTrigger());
      }
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncInitialization'});
      emit(state.copyWith(
        isLoading: false,
        onError: ErrorTypes.unknownError,
      ));
    }
  }

  Future<void> _onRequestPermissions(
    HealthSyncRequestPermissions event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      _hsLog('HealthSync: requesting permissions');
      final granted = await requestHealthPermissionsInteractor.execute();
      _hsLog('HealthSync: permissions granted=$granted');

      if (granted) {
        // Also enable sync after permissions are granted
        await toggleHealthSyncInteractor.execute(true);

        emit(state.copyWith(
          isLoading: false,
          hasPermissions: true,
          isSyncEnabled: true,
          permissionGranted: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          hasPermissions: false,
          permissionGranted: false,
        ));
      }
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncRequestPermissions'});
      emit(state.copyWith(
        isLoading: false,
        onError: ErrorTypes.unknownError,
      ));
    }
  }

  Future<void> _onToggle(
    HealthSyncToggle event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      _hsLog('HealthSync: toggle enable=${event.enable}');
      // Persist the user's intent BEFORE invoking the permission dialog. On
      // Android, the HC permission UI backgrounds our Activity and the OS may
      // kill the Flutter engine while it is paused — if we wait until after
      // the dialog to write the pref, that write never reaches disk and the
      // toggle reverts on next launch. The interactor will write the same
      // value again on its happy path, which is harmless.
      await healthSyncRepository.setHealthSyncEnabled(event.enable);

      final success = await toggleHealthSyncInteractor.execute(event.enable);
      _hsLog('HealthSync: toggle success=$success');

      if (!success && event.enable) {
        // Permission was refused (or HC missing). Revert the optimistic write
        // so the toggle does not appear stuck-on without backing permissions.
        await healthSyncRepository.setHealthSyncEnabled(false);
      }

      if (success) {
        final lastSyncTime = await healthSyncRepository.getLastSyncTime();

        if (event.enable) {
          _startPeriodicSync();
        } else {
          _stopPeriodicSync();
        }

        emit(state.copyWith(
          isLoading: false,
          isSyncEnabled: event.enable,
          hasPermissions: event.enable, // If enable succeeded, we have permissions
          lastSyncTime: lastSyncTime,
        ));
      } else {
        // Toggle failed — re-check actual state
        final hasPermissions = await healthSyncRepository.hasPermissions();
        final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
        _hsLog('HealthSync: toggle failed, hasPermissions=$hasPermissions, isEnabled=$isEnabled');

        emit(state.copyWith(
          isLoading: false,
          isSyncEnabled: isEnabled,
          hasPermissions: hasPermissions,
          permissionGranted: event.enable ? false : null,
        ));
      }
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncToggle', 'enable': '${event.enable}'});
      emit(state.copyWith(
        isLoading: false,
        onError: ErrorTypes.unknownError,
      ));
    }
  }

  Future<void> _onManualTrigger(
    HealthSyncManualTrigger event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isSyncing: true,
    ));

    try {
      _hsLog('HealthSync: manual trigger started');
      final syncResult = await syncHealthActivitiesInteractor.execute(
        since: DateTime.now().subtract(const Duration(days: 7)),
      );
      final syncedActivities = syncResult.syncedEvents;
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();
      _hsLog('HealthSync: synced ${syncedActivities.length} activities '
          '(outcome: ${syncResult.outcome.name})');

      if (syncedActivities.isNotEmpty) {
        DashboardEventBus.instance.notify(DataChangedCategory.sport);
      }

      // Fetch today's sleep/step data, save to Hive + DynamoDB
      final today = DateTime.now();
      final fresh = await _fetchAndSave(today);
      final estimatedSteps = await _calculateEstimatedSteps(today);

      // Map the sync's permission resolution onto UI attention. copyWith
      // falls back with `?? this.x`, so passing null leaves a field untouched
      // while an explicit false overrides it — tolerated syncs actively CLEAR
      // needsPermissionUpdate; resolution-free syncs change neither field.
      bool? hasPermissionsUpdate;
      bool? needsPermissionUpdate;
      switch (syncResult.permissionResolution) {
        case SyncPermissionResolution.verifiedDenial:
          hasPermissionsUpdate = false;
          needsPermissionUpdate = true;
        case SyncPermissionResolution.toleratedFalseNegative:
          hasPermissionsUpdate = true;
          needsPermissionUpdate = false;
        case SyncPermissionResolution.none:
          break;
      }

      emit(state.copyWith(
        isLoading: false,
        isSyncing: false,
        lastSyncTime: lastSyncTime,
        syncedActivitiesCount: syncedActivities.length,
        syncSuccess: syncResult.isSuccess,
        todaySleepHours: fresh.sleepHours,
        todayStepCount: fresh.stepCount,
        estimatedStepCount: estimatedSteps,
        hasPermissions: hasPermissionsUpdate,
        needsPermissionUpdate: needsPermissionUpdate,
      ));
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncManualTrigger'});
      emit(state.copyWith(
        isLoading: false,
        isSyncing: false,
        onError: ErrorTypes.unknownError,
      ));
    }
  }

  /// Load saved sleep/step data for a specific date from Hive.
  Future<void> _onLoadForDate(
    HealthSyncLoadForDate event,
    Emitter<HealthSyncState> emit,
  ) async {
    try {
      final sleepHours = await healthSyncRepository.getSavedSleepHours(event.date);
      final stepCount = await healthSyncRepository.getSavedStepCount(event.date);
      final estimatedSteps = await _calculateEstimatedSteps(event.date);
      _hsLog('HealthSync loadForDate: ${event.date}, sleep=$sleepHours, steps=$stepCount, estimated=$estimatedSteps');

      emit(state.copyWith(
        todaySleepHours: sleepHours,
        todayStepCount: stepCount,
        estimatedStepCount: estimatedSteps,
        clearSleepHours: sleepHours == null,
        clearStepCount: stepCount == null,
      ));
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncLoadForDate'});
    }
  }

  /// Re-request permissions after an app update added new health data types.
  Future<void> _onUpdatePermissions(
    HealthSyncUpdatePermissions event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      _hsLog('HealthSync: re-requesting permissions for updated data types');
      final granted = await healthSyncRepository.requestPermissions();
      _hsLog('HealthSync: permission update granted=$granted');

      if (granted) {
        // Re-run init to pick up the new permissions and fetch data
        emit(state.copyWith(
          isLoading: false,
          hasPermissions: true,
          needsPermissionUpdate: false,
        ));
        add(HealthSyncInitialization());
      } else {
        emit(state.copyWith(
          isLoading: false,
          needsPermissionUpdate: true,
        ));
      }
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncUpdatePermissions'});
      emit(state.copyWith(
        isLoading: false,
        onError: ErrorTypes.unknownError,
      ));
    }
  }

  Future<void> _onInstallHealthConnect(
    HealthSyncInstallHealthConnect event,
    Emitter<HealthSyncState> emit,
  ) async {
    try {
      await healthSyncRepository.installHealthConnect();
      // After returning from Play Store, re-check availability
      final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
      emit(state.copyWith(isAvailable: isAvailable));
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncInstallHealthConnect'});
    }
  }

  Future<void> _onOpenHealthConnect(
    HealthSyncOpenHealthConnect event,
    Emitter<HealthSyncState> emit,
  ) async {
    try {
      await healthSyncRepository.openHealthConnect();
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'HealthSyncOpenHealthConnect'});
    }
  }

  /// Calculate estimated steps from manual sport events for a given date.
  Future<int> _calculateEstimatedSteps(DateTime date) async {
    try {
      final sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      if (sportsInfo is! SportsInfoMaster) return 0;

      final sportEvents = await getTodaySportsInteractor.execute(dateTime: date);
      return estimateStepsFromSportEvents(sportEvents, sportsInfo);
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'event': 'CalculateEstimatedSteps'});
      return 0;
    }
  }

  Future<void> _onRecalculateEstimatedSteps(
    HealthSyncRecalculateEstimatedSteps event,
    Emitter<HealthSyncState> emit,
  ) async {
    final date = event.date ?? DateTime.now();
    final estimated = await _calculateEstimatedSteps(date);
    _hsLog('HealthSync: estimated steps from sport events = $estimated');
    emit(state.copyWith(estimatedStepCount: estimated));
  }
}
