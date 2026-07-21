/// Exclusive best-fit attribution of one enrichment record (energy, distance,
/// heart rate) to at most ONE workout window — the T20 fix for window-summed
/// cross-contamination of overlapping workouts.
///
/// Candidacy uses the exact overlap predicate the repository has always used
/// (strict open interval: `start1 < end2 && end1 > start2`). Parity with the
/// pre-T20 per-window sums holds for a workout whose overlapping enrichment
/// records overlap no other workout window; a record that bridges multiple
/// workout windows (even ones that do not overlap each other) is now
/// attributed to its single best-fit window instead of being summed into
/// every window it touches.
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
    int bestOverlapUs = -1;
    int bestUnionUs = 0;
    bool bestSourceMatch = false;

    for (var i = 0; i < windows.length; i++) {
      final w = windows[i];
      final overlaps =
          recordStart.isBefore(w.end) && recordEnd.isAfter(w.start);
      if (!overlaps) continue;

      final overlapUs = _minUs(recordEnd, w.end) - _maxUs(recordStart, w.start);
      final unionUs = _maxUs(recordEnd, w.end) - _minUs(recordStart, w.start);
      final sourceMatch = w.sourceName == recordSourceName;

      final wins =
          best == null ||
          overlapUs > bestOverlapUs ||
          (overlapUs == bestOverlapUs &&
              (unionUs < bestUnionUs ||
                  (unionUs == bestUnionUs &&
                      ((sourceMatch && !bestSourceMatch) ||
                          (sourceMatch == bestSourceMatch &&
                              w.start.isBefore(windows[best].start))))));
      if (wins) {
        best = i;
        bestOverlapUs = overlapUs;
        bestUnionUs = unionUs;
        bestSourceMatch = sourceMatch;
      }
    }
    return best;
  }

  static int _minUs(DateTime a, DateTime b) =>
      a.isBefore(b) ? a.microsecondsSinceEpoch : b.microsecondsSinceEpoch;
  static int _maxUs(DateTime a, DateTime b) =>
      a.isAfter(b) ? a.microsecondsSinceEpoch : b.microsecondsSinceEpoch;
}
