/// Typed outcome of a health-platform fetch.
///
/// Lets callers distinguish a genuinely empty read ([HealthFetchStatus.successNoData])
/// from a permission, platform, partial, or generic failure without inferring
/// intent from an empty list or a `null`. Introduced by T3 for the workout
/// path only; later reliability work (T8) switches on [status].
///
/// Plain immutable class — no `==`/`hashCode` override (the codebase uses
/// neither `equatable` nor `freezed`). Tests assert on individual fields.
enum HealthFetchStatus {
  /// Read succeeded and returned at least one record.
  success,

  /// Read succeeded and returned zero records.
  successNoData,

  /// Platform reported a missing permission.
  permissionDenied,

  /// HealthKit / Health Connect is unavailable on this device.
  platformUnavailable,

  /// Plugin or otherwise unclassified error.
  failed,

  /// Multi-read: primary read OK but enrichment failed. Reserved for T8;
  /// NOT produced by the T3 workout path.
  partialSuccess,
}

/// Finer-grained detail for failure-ish statuses. Callers branch on
/// [HealthFetchStatus]; [HealthFetchFailureReason] is for logging/diagnostics.
enum HealthFetchFailureReason {
  permission,
  platformUnavailable,
  pluginError,
  timeout,
  malformedData,
  unknown,
}

/// Immutable, generic result of a health fetch.
class HealthFetchResult<T> {
  final HealthFetchStatus status;
  final T? data;

  /// Optional finer detail for failure-ish statuses.
  final HealthFetchFailureReason? failureReason;

  /// Category-level message ONLY — never raw health data (no source names,
  /// exact timestamps, IDs, or user identifiers).
  final String? failureMessage;

  const HealthFetchResult._({
    required this.status,
    this.data,
    this.failureReason,
    this.failureMessage,
  });

  const HealthFetchResult.success(T data)
    : this._(status: HealthFetchStatus.success, data: data);

  const HealthFetchResult.successNoData(T data)
    : this._(status: HealthFetchStatus.successNoData, data: data);

  const HealthFetchResult.permissionDenied({String? message})
    : this._(
        status: HealthFetchStatus.permissionDenied,
        failureReason: HealthFetchFailureReason.permission,
        failureMessage: message,
      );

  const HealthFetchResult.platformUnavailable({String? message})
    : this._(
        status: HealthFetchStatus.platformUnavailable,
        failureReason: HealthFetchFailureReason.platformUnavailable,
        failureMessage: message,
      );

  const HealthFetchResult.failed({
    HealthFetchFailureReason reason = HealthFetchFailureReason.unknown,
    String? message,
  }) : this._(
         status: HealthFetchStatus.failed,
         failureReason: reason,
         failureMessage: message,
       );

  const HealthFetchResult.partialSuccess(
    T data, {
    HealthFetchFailureReason? reason,
    String? message,
  }) : this._(
         status: HealthFetchStatus.partialSuccess,
         data: data,
         failureReason: reason,
         failureMessage: message,
       );

  bool get isSuccess =>
      status == HealthFetchStatus.success ||
      status == HealthFetchStatus.successNoData;

  bool get hasData {
    final d = data;
    return d != null && !(d is Iterable && d.isEmpty);
  }
}
