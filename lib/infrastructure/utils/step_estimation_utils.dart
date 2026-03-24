import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

/// Estimates equivalent steps from manual sport events using the MET-based
/// formula: steps = (METs - 1) × 32 × minutes per activity.
///
/// Only manual entries are counted — events synced from Health Connect or
/// Apple Health already contribute real steps via the health platform.
int estimateStepsFromSportEvents(
  List<SportEventComplete> sportEvents,
  SportsInfoMaster sportsInfo,
) {
  // Build lookup: sport id → mets
  final metsMap = <int, int>{};
  for (final sport in sportsInfo.sportsInfoMaster) {
    metsMap[sport.id] = sport.mets;
  }

  int totalSteps = 0;
  for (final event in sportEvents) {
    // Skip synced events — their steps are already in Health Connect count
    if (event.source != null && event.source != 'manual') continue;

    for (final info in event.info ?? []) {
      final mets = metsMap[info.id] ?? 0;
      if (mets > 1) {
        totalSteps += ((mets - 1) * 32 * info.minutes).toInt();
      }
    }
  }
  return totalSteps;
}
