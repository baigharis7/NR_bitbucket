/// Privacy-safe classification of a diagnostic occurrence in the health-sync
/// pipeline. Pure data — intentionally free of any Firebase or platform
/// imports so events can be constructed directly in unit tests.
enum HealthSyncDiagnosticType {
  syncStarted,
  syncCompleted,
  syncSkipped,
  fetchSucceeded,
  fetchNoData,
  fetchFailed,
  permissionDenied,
  permissionFalseNegativeTolerated,
  platformUnavailable,
  sourceSelected,
  duplicateDiscarded,
  identityMissing,
  backgroundSyncSkipped,
}

enum HealthSyncDiagnosticSeverity { debug, info, warning, error }

enum HealthSyncDomain {
  workout,
  steps,
  sleep,
  permissions,
  availability,
  identity,
  background,
}

/// A single privacy-safe diagnostic observation.
///
/// [metadata] must only ever contain sanitized values — counts, coarse
/// categories, coarse platform, and day-bucketed (`yyyy-MM-dd`) dates. It must
/// never carry raw source display names, exact timestamps, raw platform/workout
/// IDs, user identifiers, or full error messages/stacktraces.
class HealthSyncDiagnosticEvent {
  final HealthSyncDiagnosticType type;
  final HealthSyncDiagnosticSeverity severity;
  final HealthSyncDomain domain;

  /// Coarse platform only: 'android', 'ios', or null.
  final String? platform;

  /// Sanitized fields only. Defaults to a const empty map.
  final Map<String, Object> metadata;

  const HealthSyncDiagnosticEvent({
    required this.type,
    required this.severity,
    required this.domain,
    this.platform,
    this.metadata = const {},
  });
}
