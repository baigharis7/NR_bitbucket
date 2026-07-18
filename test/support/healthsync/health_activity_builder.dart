import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';

/// Sentinel distinguishing "argument omitted" from "explicit null" for the
/// nullable fields (`caloriesBurned`/`distance`/`avgHeartRate`).
const Object _unset = Object();

/// Builder for the domain [HealthActivity] with defaults matching the
/// interactor tests' canonical "Apple Health running" activity.
class HealthActivityBuilder {
  final String healthPlatformId;

  /// Explicit legacy id, or null to derive `'<sourceName>_<startMs>_<endMs>'`
  /// at build time (mirrors production synthesis).
  final String? legacyPlatformId;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double? caloriesBurned;
  final double? distance;
  final int? avgHeartRate;
  final String sourceName;
  final String sourceType;

  HealthActivityBuilder({
    this.healthPlatformId = 'test-activity-id',
    this.legacyPlatformId,
    this.activityType = 'RUNNING',
    DateTime? startTime,
    DateTime? endTime,
    this.durationMinutes = 60,
    this.caloriesBurned = 500.0,
    this.distance = 10000.0,
    this.avgHeartRate = 150,
    this.sourceName = 'Apple Health',
    this.sourceType = 'apple_health',
  }) : startTime = startTime ?? DateTime(2026, 7, 1, 8, 0),
       endTime = endTime ?? DateTime(2026, 7, 1, 9, 0);

  HealthActivityBuilder copyWith({
    String? healthPlatformId,
    String? legacyPlatformId,
    String? activityType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    Object? caloriesBurned = _unset,
    Object? distance = _unset,
    Object? avgHeartRate = _unset,
    String? sourceName,
    String? sourceType,
  }) {
    return HealthActivityBuilder(
      healthPlatformId: healthPlatformId ?? this.healthPlatformId,
      legacyPlatformId: legacyPlatformId ?? this.legacyPlatformId,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned == _unset
          ? this.caloriesBurned
          : (caloriesBurned as num?)?.toDouble(),
      distance: distance == _unset
          ? this.distance
          : (distance as num?)?.toDouble(),
      avgHeartRate: avgHeartRate == _unset
          ? this.avgHeartRate
          : (avgHeartRate as num?)?.toInt(),
      sourceName: sourceName ?? this.sourceName,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  HealthActivity build() => HealthActivity(
    healthPlatformId: healthPlatformId,
    legacyPlatformId:
        legacyPlatformId ??
        '${sourceName}_${startTime.millisecondsSinceEpoch}_${endTime.millisecondsSinceEpoch}',
    activityType: activityType,
    startTime: startTime,
    endTime: endTime,
    durationMinutes: durationMinutes,
    caloriesBurned: caloriesBurned,
    distance: distance,
    avgHeartRate: avgHeartRate,
    sourceName: sourceName,
    sourceType: sourceType,
  );
}

/// Top-level convenience wrapper over [HealthActivityBuilder]. Nullable fields
/// accept an explicit `null`; omitting them keeps the canonical default.
HealthActivity aHealthActivity({
  String? healthPlatformId,
  String? legacyPlatformId,
  String? activityType,
  DateTime? startTime,
  DateTime? endTime,
  int? durationMinutes,
  Object? caloriesBurned = _unset,
  Object? distance = _unset,
  Object? avgHeartRate = _unset,
  String? sourceName,
  String? sourceType,
}) => HealthActivityBuilder()
    .copyWith(
      healthPlatformId: healthPlatformId,
      legacyPlatformId: legacyPlatformId,
      activityType: activityType,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      distance: distance,
      avgHeartRate: avgHeartRate,
      sourceName: sourceName,
      sourceType: sourceType,
    )
    .build();
