import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';

/// One-liner [HealthFetchResult] builders for the workout list type used by the
/// sync path. Consume T3's factories; no new statuses are invented here.

HealthFetchResult<List<HealthActivity>> successResult(
  List<HealthActivity> activities,
) => HealthFetchResult<List<HealthActivity>>.success(activities);

HealthFetchResult<List<HealthActivity>> noDataResult() =>
    HealthFetchResult<List<HealthActivity>>.successNoData(
      const <HealthActivity>[],
    );

HealthFetchResult<List<HealthActivity>> failedResult({
  HealthFetchFailureReason reason = HealthFetchFailureReason.pluginError,
  String? message,
}) => HealthFetchResult<List<HealthActivity>>.failed(
  reason: reason,
  message: message,
);

HealthFetchResult<List<HealthActivity>> permissionDeniedResult({
  String? message,
}) =>
    HealthFetchResult<List<HealthActivity>>.permissionDenied(message: message);

HealthFetchResult<List<HealthActivity>> platformUnavailableResult({
  String? message,
}) => HealthFetchResult<List<HealthActivity>>.platformUnavailable(
  message: message,
);

HealthFetchResult<List<HealthActivity>> partialSuccessResult(
  List<HealthActivity> activities, {
  HealthFetchFailureReason? reason,
  String? message,
}) => HealthFetchResult<List<HealthActivity>>.partialSuccess(
  activities,
  reason: reason,
  message: message,
);
