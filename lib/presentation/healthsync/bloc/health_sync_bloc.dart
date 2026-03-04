import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

part 'health_sync_event.dart';
part 'health_sync_state.dart';

class HealthSyncBloc extends Bloc<HealthSyncEvent, HealthSyncState> {
  final HealthSyncRepository healthSyncRepository;
  final CheckHealthSyncStatusInteractor checkHealthSyncStatusInteractor;
  final RequestHealthPermissionsInteractor requestHealthPermissionsInteractor;
  final ToggleHealthSyncInteractor toggleHealthSyncInteractor;
  final SyncHealthActivitiesInteractor syncHealthActivitiesInteractor;

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

  Future<void> _onInitialization(
    HealthSyncInitialization event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
      final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
      final hasPermissions = await healthSyncRepository.hasPermissions();
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();

      emit(state.copyWith(
        isLoading: false,
        isAvailable: isAvailable,
        isSyncEnabled: isEnabled,
        hasPermissions: hasPermissions,
        lastSyncTime: lastSyncTime,
      ));
    } catch (e) {
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
      final granted = await requestHealthPermissionsInteractor.execute();

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
    } catch (e) {
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
      final success = await toggleHealthSyncInteractor.execute(event.enable);

      if (success) {
        final lastSyncTime = await healthSyncRepository.getLastSyncTime();

        emit(state.copyWith(
          isLoading: false,
          isSyncEnabled: event.enable,
          hasPermissions: event.enable, // If enable succeeded, we have permissions
          lastSyncTime: lastSyncTime,
        ));
      } else {
        // Toggle failed - likely permissions denied or Health Connect not available
        // Re-check actual state and update UI accordingly
        final hasPermissions = await healthSyncRepository.hasPermissions();
        final isEnabled = await healthSyncRepository.isHealthSyncEnabled();

        emit(state.copyWith(
          isLoading: false,
          isSyncEnabled: isEnabled,
          hasPermissions: hasPermissions,
          permissionGranted: event.enable ? false : null, // Signal permission was denied
        ));
      }
    } catch (e) {
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
      final syncedActivities = await syncHealthActivitiesInteractor.execute();
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();

      if (syncedActivities.isNotEmpty) {
        DashboardEventBus.instance.notify(DataChangedCategory.sport);
      }

      emit(state.copyWith(
        isLoading: false,
        isSyncing: false,
        lastSyncTime: lastSyncTime,
        syncedActivitiesCount: syncedActivities.length,
        syncSuccess: true,
      ));
    } catch (e) {
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
    } catch (e) {
      // Ignore errors - user may have cancelled or Play Store not available
    }
  }

  Future<void> _onOpenHealthConnect(
    HealthSyncOpenHealthConnect event,
    Emitter<HealthSyncState> emit,
  ) async {
    try {
      await healthSyncRepository.openHealthConnect();
    } catch (e) {
      // Ignore errors - user may have cancelled
    }
  }
}
