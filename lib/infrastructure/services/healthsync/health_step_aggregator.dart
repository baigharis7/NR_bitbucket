import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_priority.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';

/// A single platform-reported step record for one source over one interval.
class StepRecord {
  const StepRecord({
    required this.steps,
    required this.start,
    required this.end,
    required this.sourceCategory,
  });

  final int steps;
  final DateTime start;
  final DateTime end;
  final HealthSourceCategory sourceCategory;
}

/// How a [StepAggregationResult.total] was derived.
enum StepAggregationStrategy {
  /// The platform's own cross-source aggregate was authoritative.
  platformAggregate,

  /// No platform aggregate was available; the highest-priority source's
  /// own total was used instead.
  clientPrioritySource,

  /// No aggregate and no records.
  empty,
}

/// Result of [HealthStepAggregator.aggregate].
class StepAggregationResult {
  const StepAggregationResult({
    required this.total,
    required this.strategy,
    required this.perSourceTotals,
    required this.selectedCategory,
    required this.discardedCount,
  });

  final int total;
  final StepAggregationStrategy strategy;
  final Map<HealthSourceCategory, int> perSourceTotals;
  final HealthSourceCategory? selectedCategory;
  final int discardedCount;
}

/// Deterministic, order-independent step aggregation across health sources.
///
/// LOCKED CONTRACT: shape mirrored verbatim by the sleep-aggregation
/// counterpart — do not change these member names without updating that
/// mirror too.
///
/// Policy: when the platform reports its own cross-source total, trust it
/// (it already dedupes overlapping sources internally). Only fall back to
/// summing our own per-source records — from the single highest-priority
/// source, never a cross-source sum — when no platform aggregate is
/// available.
class HealthStepAggregator {
  const HealthStepAggregator();

  StepAggregationResult aggregate({
    int? platformAggregateTotal,
    required List<StepRecord> records,
  }) {
    final deduped = _dedupe(records);
    final exactDupDrops = records.length - deduped.length;

    final perSourceTotals = <HealthSourceCategory, int>{};
    for (final record in deduped) {
      perSourceTotals.update(
        record.sourceCategory,
        (total) => total + record.steps,
        ifAbsent: () => record.steps,
      );
    }

    if (platformAggregateTotal != null) {
      final selectedCategory = perSourceTotals.isEmpty
          ? null
          : const HealthSourcePriority().highestOf(perSourceTotals.keys);
      return StepAggregationResult(
        total: platformAggregateTotal,
        strategy: StepAggregationStrategy.platformAggregate,
        perSourceTotals: perSourceTotals,
        selectedCategory: selectedCategory,
        discardedCount: exactDupDrops,
      );
    }

    if (perSourceTotals.isNotEmpty) {
      final selectedCategory = const HealthSourcePriority().highestOf(
        perSourceTotals.keys,
      );
      final nonSelectedCount = deduped
          .where((record) => record.sourceCategory != selectedCategory)
          .length;
      return StepAggregationResult(
        total: perSourceTotals[selectedCategory]!,
        strategy: StepAggregationStrategy.clientPrioritySource,
        perSourceTotals: perSourceTotals,
        selectedCategory: selectedCategory,
        discardedCount: exactDupDrops + nonSelectedCount,
      );
    }

    return StepAggregationResult(
      total: 0,
      strategy: StepAggregationStrategy.empty,
      perSourceTotals: perSourceTotals,
      selectedCategory: null,
      discardedCount: exactDupDrops,
    );
  }

  /// Drops exact duplicates (same steps + start + end + sourceCategory),
  /// keeping the first occurrence. Order-independent: the notion of "which
  /// one is dropped" doesn't matter since duplicates are identical.
  List<StepRecord> _dedupe(List<StepRecord> records) {
    final seen = <String>{};
    final result = <StepRecord>[];
    for (final record in records) {
      final key =
          '${record.steps}_${record.start.millisecondsSinceEpoch}_'
          '${record.end.millisecondsSinceEpoch}_${record.sourceCategory}';
      if (seen.add(key)) {
        result.add(record);
      }
    }
    return result;
  }
}
