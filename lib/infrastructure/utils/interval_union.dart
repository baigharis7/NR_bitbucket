/// A simple half-open time interval [from, to).
class TimeInterval {
  final DateTime from;
  final DateTime to;
  const TimeInterval(this.from, this.to);
}

/// Return the total number of minutes covered by [intervals], counting any
/// overlap only once. Empty or zero/negative-length intervals are ignored.
///
/// Used by HealthSync to deduplicate sleep sessions that multiple Health
/// Connect data sources (Samsung Health, Google Fit, smartwatch app) may
/// each log for the same night.
int sumNonOverlappingMinutes(Iterable<TimeInterval> intervals) {
  final sorted = intervals.where((i) => i.to.isAfter(i.from)).toList()
    ..sort((a, b) => a.from.compareTo(b.from));
  if (sorted.isEmpty) return 0;

  int totalMinutes = 0;
  DateTime mergeFrom = sorted.first.from;
  DateTime mergeTo = sorted.first.to;
  for (int i = 1; i < sorted.length; i++) {
    final cur = sorted[i];
    if (cur.from.isAfter(mergeTo)) {
      totalMinutes += mergeTo.difference(mergeFrom).inMinutes;
      mergeFrom = cur.from;
      mergeTo = cur.to;
    } else if (cur.to.isAfter(mergeTo)) {
      mergeTo = cur.to;
    }
  }
  totalMinutes += mergeTo.difference(mergeFrom).inMinutes;
  return totalMinutes;
}
