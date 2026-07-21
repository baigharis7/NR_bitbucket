/// Exclusive best-fit attribution of one enrichment record (energy, distance,
/// heart rate) to at most ONE workout window — the T20 fix for window-summed
/// cross-contamination of overlapping workouts.
///
/// Candidacy uses the exact overlap predicate the repository has always used
/// (strict open interval: `start1 < end2 && end1 > start2`), so a single
/// non-overlapping workout receives exactly the records it receives today.
class WorkoutAttributionWindow {
  final DateTime start;
  final DateTime end;
  final String sourceName;

  const WorkoutAttributionWindow({
    required this.start,
    required this.end,
    required this.sourceName,
  });
}

class HealthWorkoutRecordAttribution {
  HealthWorkoutRecordAttribution._();

  /// Index into [windows] of the workout this record enriches, or null when
  /// the record overlaps no window. Deterministic ladder among overlapping
  /// candidates: (1) max overlap duration, (2) min union duration (tightest
  /// window — also resolves zero-duration samples contained in nested
  /// windows), (3) matching [recordSourceName], (4) earlier window start,
  /// (5) lower index.
  static int? attributeIndex({
    required DateTime recordStart,
    required DateTime recordEnd,
    required String recordSourceName,
    required List<WorkoutAttributionWindow> windows,
  }) {
    int? best;
    int bestOverlapMs = -1;
    int bestUnionMs = 0;
    bool bestSourceMatch = false;

    for (var i = 0; i < windows.length; i++) {
      final w = windows[i];
      final overlaps =
          recordStart.isBefore(w.end) && recordEnd.isAfter(w.start);
      if (!overlaps) continue;

      final overlapMs = _minMs(recordEnd, w.end) - _maxMs(recordStart, w.start);
      final unionMs = _maxMs(recordEnd, w.end) - _minMs(recordStart, w.start);
      final sourceMatch = w.sourceName == recordSourceName;

      final wins =
          best == null ||
          overlapMs > bestOverlapMs ||
          (overlapMs == bestOverlapMs &&
              (unionMs < bestUnionMs ||
                  (unionMs == bestUnionMs &&
                      ((sourceMatch && !bestSourceMatch) ||
                          (sourceMatch == bestSourceMatch &&
                              w.start.isBefore(windows[best].start))))));
      if (wins) {
        best = i;
        bestOverlapMs = overlapMs;
        bestUnionMs = unionMs;
        bestSourceMatch = sourceMatch;
      }
    }
    return best;
  }

  static int _minMs(DateTime a, DateTime b) =>
      a.isBefore(b) ? a.millisecondsSinceEpoch : b.millisecondsSinceEpoch;
  static int _maxMs(DateTime a, DateTime b) =>
      a.isAfter(b) ? a.millisecondsSinceEpoch : b.millisecondsSinceEpoch;
}
