part of 'health_sync_bloc.dart';

class HealthSyncState {
  final bool isLoading;
  final bool isAvailable;
  final bool hasPermissions;
  final bool isSyncEnabled;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int? syncedActivitiesCount;
  final ErrorTypes? onError;
  final bool? permissionGranted;
  final bool? syncSuccess;
  final double? todaySleepHours;
  final int? todayStepCount;

  HealthSyncState({
    this.isLoading = false,
    this.isAvailable = false,
    this.hasPermissions = false,
    this.isSyncEnabled = false,
    this.isSyncing = false,
    this.lastSyncTime,
    this.syncedActivitiesCount,
    this.onError,
    this.permissionGranted,
    this.syncSuccess,
    this.todaySleepHours,
    this.todayStepCount,
  });

  HealthSyncState copyWith({
    bool? isLoading,
    bool? isAvailable,
    bool? hasPermissions,
    bool? isSyncEnabled,
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? syncedActivitiesCount,
    ErrorTypes? onError,
    bool? permissionGranted,
    bool? syncSuccess,
    double? todaySleepHours,
    int? todayStepCount,
  }) {
    return HealthSyncState(
      isLoading: isLoading ?? this.isLoading,
      isAvailable: isAvailable ?? this.isAvailable,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isSyncEnabled: isSyncEnabled ?? this.isSyncEnabled,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncedActivitiesCount: syncedActivitiesCount ?? this.syncedActivitiesCount,
      onError: onError,
      permissionGranted: permissionGranted,
      syncSuccess: syncSuccess,
      todaySleepHours: todaySleepHours ?? this.todaySleepHours,
      todayStepCount: todayStepCount ?? this.todayStepCount,
    );
  }
}
