import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/interval_union.dart';

void main() {
  DateTime t(int hour, [int minute = 0]) =>
      DateTime(2026, 5, 15, hour, minute);

  group('sumNonOverlappingMinutes', () {
    test('returns 0 for an empty iterable', () {
      expect(sumNonOverlappingMinutes(const []), 0);
    });

    test('returns the duration of a single interval', () {
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 7))),
      ]);
      expect(result, 7 * 60);
    });

    test('sums two disjoint intervals', () {
      // 23:00–06:00 (7h) + 13:00–13:30 (30m nap) = 450 min
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 7))),
        TimeInterval(t(13), t(13, 30)),
      ]);
      expect(result, 7 * 60 + 30);
    });

    test('deduplicates two identical intervals', () {
      // Same night logged by two apps → count once
      final a = TimeInterval(t(23), t(23).add(const Duration(hours: 7)));
      final b = TimeInterval(t(23), t(23).add(const Duration(hours: 7)));
      expect(sumNonOverlappingMinutes([a, b]), 7 * 60);
    });

    test('merges partially overlapping intervals', () {
      // 23:00–06:00 (Samsung) and 23:30–06:30 (Google Fit) → 23:00–06:30 = 7.5h
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 7))),
        TimeInterval(t(23, 30), t(23, 30).add(const Duration(hours: 7))),
      ]);
      expect(result, 450); // 7h30m
    });

    test('absorbs an interval fully contained in another', () {
      // Long session 23:00–07:00, with a short 01:00–02:00 inside it
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 8))),
        TimeInterval(
          t(23).add(const Duration(hours: 2)),
          t(23).add(const Duration(hours: 3)),
        ),
      ]);
      expect(result, 8 * 60);
    });

    test('handles unsorted input', () {
      // Three nights mixed in arbitrary order
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(13), t(13, 30)),
        TimeInterval(t(23), t(23).add(const Duration(hours: 7))),
        TimeInterval(t(15), t(15, 15)),
      ]);
      expect(result, 7 * 60 + 30 + 15);
    });

    test('skips zero or negative-length intervals', () {
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 7))),
        TimeInterval(t(10), t(10)), // zero
        TimeInterval(t(12), t(11)), // negative
      ]);
      expect(result, 7 * 60);
    });

    test('merges a chain of overlapping intervals', () {
      // A → overlaps B → overlaps C, all merge into a single span
      final result = sumNonOverlappingMinutes([
        TimeInterval(t(23), t(23).add(const Duration(hours: 2))),    // 23:00–01:00
        TimeInterval(t(23).add(const Duration(hours: 1)), t(23).add(const Duration(hours: 4))),  // 00:00–03:00
        TimeInterval(t(23).add(const Duration(hours: 3)), t(23).add(const Duration(hours: 6))),  // 02:00–05:00
      ]);
      // Union span 23:00 → 05:00 = 6h
      expect(result, 6 * 60);
    });
  });
}
