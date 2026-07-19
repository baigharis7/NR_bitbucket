import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_step_aggregator.dart';

void main() {
  const aggregator = HealthStepAggregator();
  final start = DateTime(2026, 7, 10, 8, 0);
  final end = DateTime(2026, 7, 10, 9, 0);
  final otherStart = DateTime(2026, 7, 10, 10, 0);
  final otherEnd = DateTime(2026, 7, 10, 11, 0);

  StepRecord watch({
    int steps = 9000,
    DateTime? recordStart,
    DateTime? recordEnd,
  }) => StepRecord(
    steps: steps,
    start: recordStart ?? start,
    end: recordEnd ?? end,
    sourceCategory: HealthSourceCategory.appleWatch,
  );

  StepRecord phone({
    int steps = 6000,
    DateTime? recordStart,
    DateTime? recordEnd,
  }) => StepRecord(
    steps: steps,
    start: recordStart ?? start,
    end: recordEnd ?? end,
    sourceCategory: HealthSourceCategory.healthConnectApp,
  );

  group('platform aggregate wins', () {
    test('uses the platform total and does not double-count overlapping '
        'cross-source records', () {
      final result = aggregator.aggregate(
        platformAggregateTotal: 9000,
        records: [watch(steps: 9000), phone(steps: 6000)],
      );

      expect(result.total, 9000);
      expect(result.strategy, StepAggregationStrategy.platformAggregate);
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.perSourceTotals, {
        HealthSourceCategory.appleWatch: 9000,
        HealthSourceCategory.healthConnectApp: 6000,
      });
      expect(result.discardedCount, 0);
    });
  });

  group('fallback when aggregate is null', () {
    test(
      'uses the highest-priority source total, not the sum of all sources',
      () {
        final result = aggregator.aggregate(
          platformAggregateTotal: null,
          records: [watch(steps: 9000), phone(steps: 6000)],
        );

        expect(result.total, 9000);
        expect(result.strategy, StepAggregationStrategy.clientPrioritySource);
        expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      },
    );

    test('discardedCount counts the non-selected-category records', () {
      final result = aggregator.aggregate(
        platformAggregateTotal: null,
        records: [
          watch(steps: 9000),
          phone(steps: 6000),
          phone(steps: 1000, recordStart: otherStart, recordEnd: otherEnd),
        ],
      );

      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.discardedCount, 2);
    });
  });

  group('exact-duplicate dedup', () {
    test('two identical records are counted once; discardedCount == 1', () {
      final record = watch(steps: 9000);
      final result = aggregator.aggregate(
        platformAggregateTotal: null,
        records: [record, watch(steps: 9000)],
      );

      expect(result.total, 9000);
      expect(result.perSourceTotals, {HealthSourceCategory.appleWatch: 9000});
      expect(result.discardedCount, 1);
    });
  });

  group('same-source non-overlapping sum', () {
    test('two non-overlapping records from one source are summed', () {
      final result = aggregator.aggregate(
        platformAggregateTotal: null,
        records: [
          watch(steps: 4000),
          watch(steps: 3000, recordStart: otherStart, recordEnd: otherEnd),
        ],
      );

      expect(result.total, 7000);
      expect(result.strategy, StepAggregationStrategy.clientPrioritySource);
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.discardedCount, 0);
    });
  });

  group('order independence', () {
    final records = [
      watch(steps: 9000),
      phone(steps: 6000),
      phone(steps: 1000, recordStart: otherStart, recordEnd: otherEnd),
    ];

    test('shuffled/reversed order yields identical results with a platform '
        'aggregate present', () {
      final forward = aggregator.aggregate(
        platformAggregateTotal: 9000,
        records: records,
      );
      final reversed = aggregator.aggregate(
        platformAggregateTotal: 9000,
        records: records.reversed.toList(),
      );

      expect(reversed.total, forward.total);
      expect(reversed.selectedCategory, forward.selectedCategory);
      expect(reversed.perSourceTotals, forward.perSourceTotals);
    });

    test(
      'shuffled/reversed order yields identical results in the fallback path',
      () {
        final forward = aggregator.aggregate(
          platformAggregateTotal: null,
          records: records,
        );
        final reversed = aggregator.aggregate(
          platformAggregateTotal: null,
          records: records.reversed.toList(),
        );

        expect(reversed.total, forward.total);
        expect(reversed.selectedCategory, forward.selectedCategory);
        expect(reversed.perSourceTotals, forward.perSourceTotals);
      },
    );
  });

  group('empty', () {
    test('no records and no aggregate yields total 0, strategy empty', () {
      final result = aggregator.aggregate(
        platformAggregateTotal: null,
        records: const [],
      );

      expect(result.total, 0);
      expect(result.strategy, StepAggregationStrategy.empty);
      expect(result.selectedCategory, isNull);
      expect(result.discardedCount, 0);
    });

    test(
      'no records but a zero platform aggregate still uses platformAggregate',
      () {
        final result = aggregator.aggregate(
          platformAggregateTotal: 0,
          records: const [],
        );

        expect(result.total, 0);
        expect(result.strategy, StepAggregationStrategy.platformAggregate);
        expect(result.selectedCategory, isNull);
        expect(result.discardedCount, 0);
      },
    );
  });
}
