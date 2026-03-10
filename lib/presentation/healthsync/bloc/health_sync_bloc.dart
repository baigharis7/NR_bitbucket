import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

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

  static const _periodicSyncInterval = Duration(minutes: 5);
  Timer? _periodicSyncTimer;

  HealthSyncBloc({
    required this.healthSyncRepository,
    required this.checkHealthSyncStatusInteractor,
    required this.requestHealthPermissionsInteractor,
    required this.toggleHealthSyncInteractor,
    required this.syncHealthActivitiesInteractor,
  }) : super(HealthSyncState()) {
    on<HealthSyncInitialization>(_onInitialization);
    on<HealthSyncRequestPermissions>(_onRequestPermissions);
    on<HealthSyncToggle>(_onToggle);
    on<HealthSyncManualTrigger>(_onManualTrigger);
    on<HealthSyncInstallHealthConnect>(_onInstallHealthConnect);
    on<HealthSyncOpenHealthConnect>(_onOpenHealthConnect);
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
    return super.close();
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

      // Auto-disable sync if permissions were revoked externally (e.g. in HC settings)
      if (isEnabled && !hasPermissions && isAvailable) {
        _hsLog('HealthSync init: permissions revoked, disabling sync');
        await healthSyncRepository.setHealthSyncEnabled(false);
      }

      final lastSyncTime = await healthSyncRepository.getLastSyncTime();

      final syncEnabled = isEnabled && hasPermissions;
      if (syncEnabled) {
        _startPeriodicSync();
      } else {
        _stopPeriodicSync();
      }

      // Fetch today's sleep/step data if sync is enabled
      double? sleepHours;
      int? stepCount;
      if (syncEnabled) {
        final today = DateTime.now();
        sleepHours = await healthSyncRepository.fetchTodaySleepHours(today);
        stepCount = await healthSyncRepository.fetchTodayStepCount(today);
        _hsLog('HealthSync init: sleepHours=$sleepHours, stepCount=$stepCount');
      }

      emit(state.copyWith(
        isLoading: false,
        isAvailable: isAvailable,
        isSyncEnabled: syncEnabled,
        hasPermissions: hasPermissions,
        lastSyncTime: lastSyncTime,
        todaySleepHours: sleepHours,
        todayStepCount: stepCount,
      ));
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
      final success = await toggleHealthSyncInteractor.execute(event.enable);
      _hsLog('HealthSync: toggle success=$success');

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
      final syncedActivities = await syncHealthActivitiesInteractor.execute(
        since: DateTime.now().subtract(const Duration(days: 7)),
      );
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();
      _hsLog('HealthSync: synced ${syncedActivities.length} activities');

      if (syncedActivities.isNotEmpty) {
        DashboardEventBus.instance.notify(DataChangedCategory.sport);
      }

      // Refresh sleep/step data after sync
      final today = DateTime.now();
      final sleepHours = await healthSyncRepository.fetchTodaySleepHours(today);
      final stepCount = await healthSyncRepository.fetchTodayStepCount(today);

      emit(state.copyWith(
        isLoading: false,
        isSyncing: false,
        lastSyncTime: lastSyncTime,
        syncedActivitiesCount: syncedActivities.length,
        syncSuccess: true,
        todaySleepHours: sleepHours,
        todayStepCount: stepCount,
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
}
