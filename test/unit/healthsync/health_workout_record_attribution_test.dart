import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_record_attribution.dart';

void main() {
  final base = DateTime(2026, 7, 21, 10);
  DateTime t(int minutes) => base.add(Duration(minutes: minutes));
  WorkoutAttributionWindow w(int startMin, int endMin, {String source = 'A'}) =>
      WorkoutAttributionWindow(
        start: t(startMin),
        end: t(endMin),
        sourceName: source,
      );
  int? attr(
    int startMin,
    int endMin,
    List<WorkoutAttributionWindow> windows, {
    String source = 'A',
  }) => HealthWorkoutRecordAttribution.attributeIndex(
    recordStart: t(startMin),
    recordEnd: t(endMin),
    recordSourceName: source,
    windows: windows,
  );

  group('HealthWorkoutRecordAttribution.attributeIndex', () {
    test('single overlapping window wins', () {
      expect(attr(0, 60, [w(0, 60)]), 0);
    });

    test('no overlapping window yields null', () {
      expect(attr(120, 130, [w(0, 60)]), isNull);
    });

    test('boundary touch is NOT an overlap (matches _isOverlapping)', () {
      // record [60,70] vs window [0,60]: end1.isAfter(start2) but
      // start1.isBefore(end2) is false — excluded, same as today.
      expect(attr(60, 70, [w(0, 60)]), isNull);
    });

    test('rung 1: larger overlap duration wins (drifted duplicate pair)', () {
      final windows = [w(0, 60), w(1, 61)];
      expect(attr(0, 60, windows), 0, reason: '60 min vs 59 min overlap');
      expect(attr(1, 61, windows), 1, reason: '59 min vs 60 min overlap');
    });

    test(
      'rung 2: equal overlap resolved by tightest window (same-start pair)',
      () {
        // RUNNING [0,60], BIKING [0,30]; the biking record [0,30] overlaps
        // both by 30 min — min union (30 vs 60) must pick BIKING.
        final windows = [w(0, 60), w(0, 30)];
        expect(attr(0, 30, windows), 1);
        expect(attr(0, 60, windows), 0);
      },
    );

    test(
      'rung 2: zero-duration HR sample goes to the tightest containing window',
      () {
        final windows = [w(0, 60), w(0, 30)];
        expect(attr(15, 15, windows), 1);
        expect(
          attr(45, 45, windows),
          0,
          reason: 'only RUNNING contains minute 45',
        );
      },
    );

    test('rung 3: identical windows resolved by matching sourceName', () {
      final windows = [w(0, 60, source: 'A'), w(0, 60, source: 'B')];
      expect(attr(0, 60, windows, source: 'B'), 1);
      expect(attr(0, 60, windows, source: 'A'), 0);
    });

    test('rung 4: earlier workout start breaks remaining ties', () {
      // record [10,20] fully inside both; equal overlap (10), equal union
      // is NOT equal here — construct equal-union windows instead:
      // [0,40] and [5,45] for record [10,35]: overlap 25 both? No —
      // use truly symmetric case: windows [0,40] and [5,45], record [5,40]:
      // overlap 35 both, union 40 both, same source → earlier start wins.
      final windows = [w(5, 45), w(0, 40)];
      expect(attr(5, 40, windows), 1);
    });

    test('rung 5: fully identical candidates resolve to the lowest index', () {
      final windows = [w(0, 60), w(0, 60)];
      expect(attr(0, 60, windows), 0);
    });
  });
}
