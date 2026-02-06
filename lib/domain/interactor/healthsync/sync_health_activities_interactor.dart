import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

/// Core interactor that orchestrates health activity syncing.
/// Fetches activities from the health platform, deduplicates, maps to sport events,
/// saves locally, and uploads to the cloud.
///
/// [since] - Optional. If provided, only syncs activities after this time.
///           If null, uses the last sync time or defaults to 7 days ago.
abstract class SyncHealthActivitiesInteractor {
  Future<List<SportEventComplete>> execute({DateTime? since});
}
