import 'package:health/health.dart';

import 'health_data_point_builder.dart';
import 'health_source_fixtures.dart';

/// Same workout recorded by two sources with a small start/end drift
/// (the source-priority / dedupe scenario).
List<HealthDataPoint> duplicateWorkoutAcrossSources({
  required DateTime from,
  required DateTime to,
  HealthWorkoutActivityType activity = HealthWorkoutActivityType.RUNNING,
  HealthSource sourceA = appleWatch,
  HealthSource sourceB = iphone,
  Duration drift = const Duration(seconds: 30),
}) {
  return [
    workoutPoint(from: from, to: to, activity: activity, source: sourceA),
    workoutPoint(
      from: from.add(drift),
      to: to.add(drift),
      activity: activity,
      source: sourceB,
    ),
  ];
}

/// Two different workouts that share the same start timestamp.
List<HealthDataPoint> distinctWorkoutsSameStart({
  required DateTime start,
  Duration firstDuration = const Duration(minutes: 30),
  Duration secondDuration = const Duration(minutes: 45),
  HealthWorkoutActivityType firstActivity = HealthWorkoutActivityType.RUNNING,
  HealthWorkoutActivityType secondActivity = HealthWorkoutActivityType.WALKING,
  HealthSource source = appleWatch,
}) {
  return [
    workoutPoint(
      from: start,
      to: start.add(firstDuration),
      activity: firstActivity,
      source: source,
    ),
    workoutPoint(
      from: start,
      to: start.add(secondDuration),
      activity: secondActivity,
      source: source,
    ),
  ];
}

/// Two step records whose time windows overlap, from two sources.
List<HealthDataPoint> overlappingStepRecords({
  required DateTime from,
  required DateTime to,
  num firstSteps = 1000,
  num secondSteps = 800,
  HealthSource sourceA = phone,
  HealthSource sourceB = googleFit,
}) {
  final span = to.difference(from);
  final mid = from.add(span ~/ 2);
  return [
    numericPoint(
      type: HealthDataType.STEPS,
      value: firstSteps,
      from: from,
      to: to,
      source: sourceA,
    ),
    numericPoint(
      type: HealthDataType.STEPS,
      value: secondSteps,
      from: mid,
      to: to.add(span),
      source: sourceB,
    ),
  ];
}

/// Two sleep sessions whose windows overlap (second shifted later but still
/// starting before the first ends).
List<HealthDataPoint> overlappingSleepSessions({
  required DateTime from,
  required DateTime to,
  Duration overlapShift = const Duration(hours: 1),
  HealthSource sourceA = appleWatch,
  HealthSource sourceB = iphone,
}) {
  return [
    sleepPoint(from: from, to: to, source: sourceA),
    sleepPoint(
      from: from.add(overlapShift),
      to: to.add(overlapShift),
      source: sourceB,
    ),
  ];
}

/// A single sleep session that crosses midnight (bedtime one day, wake the
/// next). Callers pass midnight-crossing timestamps.
List<HealthDataPoint> crossMidnightSleepSession({
  required DateTime bedTime,
  required DateTime wakeTime,
  HealthSource source = appleWatch,
}) {
  return [sleepPoint(from: bedTime, to: wakeTime, source: source)];
}

/// A planned/goal sleep window plus the actual recorded session, from two
/// distinct sources.
List<HealthDataPoint> plannedSleepWindowPlusActual({
  required DateTime plannedFrom,
  required DateTime plannedTo,
  required DateTime actualFrom,
  required DateTime actualTo,
  HealthSource plannedSource = phone,
  HealthSource actualSource = appleWatch,
}) {
  return [
    sleepPoint(from: plannedFrom, to: plannedTo, source: plannedSource),
    sleepPoint(from: actualFrom, to: actualTo, source: actualSource),
  ];
}
