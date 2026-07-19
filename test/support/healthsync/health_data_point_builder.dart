import 'package:health/health.dart';

import 'health_source_fixtures.dart';

/// Default source mirroring the values the repo test's former private
/// `_point()` used, so pre-existing assertions stay unchanged after refactor.
const HealthSource _defaultSource = HealthSource(
  name: 'TestSource',
  id: 'source-id',
  deviceId: 'device',
  platform: HealthPlatformType.appleHealth,
);

/// Builds a raw [HealthDataPoint]. Mirrors the `health` package's required
/// fields; unused metadata is defaulted by the package constructor.
HealthDataPoint healthDataPoint({
  required HealthDataType type,
  required HealthValue value,
  required DateTime from,
  required DateTime to,
  HealthSource source = _defaultSource,
  String? uuid,
}) {
  return HealthDataPoint(
    uuid:
        uuid ??
        '$type-${from.millisecondsSinceEpoch}-${to.millisecondsSinceEpoch}-${source.id}',
    value: value,
    type: type,
    unit: HealthDataUnit.NO_UNIT,
    dateFrom: from,
    dateTo: to,
    sourcePlatform: source.platform,
    sourceDeviceId: source.deviceId,
    sourceId: source.id,
    sourceName: source.name,
  );
}

/// A WORKOUT point carrying a [WorkoutHealthValue]. `totalEnergyBurned` and
/// `totalDistance` are `int?` on the package type, so `num?` inputs are
/// coerced with `?.toInt()`.
HealthDataPoint workoutPoint({
  required DateTime from,
  required DateTime to,
  HealthWorkoutActivityType activity = HealthWorkoutActivityType.RUNNING,
  num? totalEnergyBurned,
  num? totalDistance,
  HealthSource source = _defaultSource,
  String? uuid,
}) {
  return healthDataPoint(
    type: HealthDataType.WORKOUT,
    value: WorkoutHealthValue(
      workoutActivityType: activity,
      totalEnergyBurned: totalEnergyBurned?.toInt(),
      totalDistance: totalDistance?.toInt(),
    ),
    from: from,
    to: to,
    source: source,
    uuid: uuid,
  );
}

/// A numeric point (steps / energy / distance / heart rate) carrying a
/// [NumericHealthValue].
HealthDataPoint numericPoint({
  required HealthDataType type,
  required num value,
  required DateTime from,
  required DateTime to,
  HealthSource source = _defaultSource,
}) {
  return healthDataPoint(
    type: type,
    value: NumericHealthValue(numericValue: value),
    from: from,
    to: to,
    source: source,
  );
}

/// A SLEEP_SESSION point (category value 0, matching the repo test).
HealthDataPoint sleepPoint({
  required DateTime from,
  required DateTime to,
  HealthSource source = _defaultSource,
}) {
  return healthDataPoint(
    type: HealthDataType.SLEEP_SESSION,
    value: NumericHealthValue(numericValue: 0),
    from: from,
    to: to,
    source: source,
  );
}
