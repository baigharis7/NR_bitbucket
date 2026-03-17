part of 'health_sync_bloc.dart';

abstract class HealthSyncEvent {}

/// Initialize the health sync state by checking availability, permissions, and status.
class HealthSyncInitialization extends HealthSyncEvent {}

/// Request health data permissions from the platform.
class HealthSyncRequestPermissions extends HealthSyncEvent {}

/// Enable or disable health data sync.
class HealthSyncToggle extends HealthSyncEvent {
  final bool enable;

  HealthSyncToggle({required this.enable});
}

/// Manually trigger a health data sync.
class HealthSyncManualTrigger extends HealthSyncEvent {}

/// Open Play Store to install Health Connect (Android only).
class HealthSyncInstallHealthConnect extends HealthSyncEvent {}

/// Open the Health Connect app directly (Android only).
class HealthSyncOpenHealthConnect extends HealthSyncEvent {}

/// Load saved sleep/step data for a specific date from local storage.
class HealthSyncLoadForDate extends HealthSyncEvent {
  final DateTime date;

  HealthSyncLoadForDate({required this.date});
}
