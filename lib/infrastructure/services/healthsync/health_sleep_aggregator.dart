import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_priority.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/interval_union.dart';

/// A single platform-reported sleep session for one source over one
/// interval.
class SleepSession {
  const SleepSession({
    required this.start,
    required this.end,
    required this.sourceCategory,
  });

  final DateTime start;
  final DateTime end;
  final HealthSourceCategory sourceCategory;
}

/// How a [SleepAggregationResult.hours] was derived.
enum SleepAggregationStrategy {
  /// The union of the highest-priority source's own sessions was used.
  prioritySourceUnion,

  /// No valid sessions were available.
  empty,
}

/// Result of [HealthSleepAggregator.aggregate].
class SleepAggregationResult {
  const SleepAggregationResult({
    required this.hours,
    required this.strategy,
    required this.selectedCategory,
    required this.sourceCount,
    required this.discardedCount,
  });

  final double hours;
  final SleepAggregationStrategy strategy;
  final HealthSourceCategory? selectedCategory;
  final int sourceCount;
  final int discardedCount;
}

/// Deterministic, order-independent sleep aggregation across health sources.
///
/// LOCKED CONTRACT: shape mirrors [health_step_aggregator.dart]'s
/// counterpart — do not change these member names without updating that
/// mirror too.
///
/// Policy: drop implausible sessions (zero/negative duration, or longer than
/// [maxPlausibleSleep] — e.g. a stale "planned sleep window" left un-closed),
/// then trust the single highest-priority source among what remains, unioning
/// that source's own sessions (never summing — a source may log overlapping
/// sessions for the same night) rather than combining across sources.
class HealthSleepAggregator {
  const HealthSleepAggregator();

  /// Sessions reporting a duration beyond this are almost certainly a stale
  /// planned/scheduled window rather than a real sleep, and are discarded.
  static const Duration maxPlausibleSleep = Duration(hours: 16);

  SleepAggregationResult aggregate({required List<SleepSession> sessions}) {
    final valid = <SleepSession>[];
    var invalidCount = 0;
    for (final session in sessions) {
      final duration = session.end.difference(session.start);
      if (duration <= Duration.zero || duration > maxPlausibleSleep) {
        invalidCount++;
      } else {
        valid.add(session);
      }
    }

    if (valid.isEmpty) {
      return SleepAggregationResult(
        hours: 0.0,
        strategy: SleepAggregationStrategy.empty,
        selectedCategory: null,
        sourceCount: 0,
        discardedCount: invalidCount,
      );
    }

    final groups = <HealthSourceCategory, List<SleepSession>>{};
    for (final session in valid) {
      groups.update(
        session.sourceCategory,
        (list) => list..add(session),
        ifAbsent: () => [session],
      );
    }

    final selectedCategory = const HealthSourcePriority().highestOf(
      groups.keys,
    );
    final selectedSessions = groups[selectedCategory]!;
    final minutes = sumNonOverlappingMinutes(
      selectedSessions.map((s) => TimeInterval(s.start, s.end)),
    );
    final nonSelectedCount = valid
        .where((session) => session.sourceCategory != selectedCategory)
        .length;

    return SleepAggregationResult(
      hours: minutes / 60.0,
      strategy: SleepAggregationStrategy.prioritySourceUnion,
      selectedCategory: selectedCategory,
      sourceCount: groups.length,
      discardedCount: invalidCount + nonSelectedCount,
    );
  }
}
