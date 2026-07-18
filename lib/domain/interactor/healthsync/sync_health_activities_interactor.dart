import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';

/// Core interactor that orchestrates health activity syncing.
/// Fetches activities from the health platform via the typed result path,
/// deduplicates, maps to sport events, saves locally, and uploads to the
/// cloud. Returns a [SyncHealthActivitiesResult] whose outcome states whether
/// the sync window advanced; the platform fetch failing means no import and
/// no lastSyncTime advancement.
///
/// [since] - Optional. If provided, only syncs activities after this time.
///           If null, uses the last sync time or defaults to 7 days ago.
abstract class SyncHealthActivitiesInteractor {
  Future<SyncHealthActivitiesResult> execute({DateTime? since});
}
