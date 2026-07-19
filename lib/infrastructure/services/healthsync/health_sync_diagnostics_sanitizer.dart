import 'dart:async';

import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';

/// Coarse error categories derived from an exception without retaining the raw
/// message or stacktrace. Used only as sanitized diagnostic metadata.
enum HealthSyncErrorCategory {
  permission,
  platformUnavailable,
  timeout,
  network,
  plugin,
  unknown,
}

/// Coarse source category retained in `sourceSelected` metadata — never a raw
/// source display name.
enum HealthSyncSourceCategory { wearable, phone, thirdPartyApp, unknown }

/// Pure builders that assemble [HealthSyncDiagnosticEvent]s carrying only
/// privacy-safe fields: counts, coarse categories, coarse platform, and
/// day-bucketed dates. No Firebase, no raw health payloads.
class HealthSyncDiagnostics {
  const HealthSyncDiagnostics._();

  /// Builds a `fetchFailed` event. Only a coarse [HealthSyncErrorCategory] is
  /// retained in metadata — never the raw message or stacktrace. Provide
  /// either the thrown [error] (classified via [classify]) or an
  /// already-classified [category] when the caller no longer holds the
  /// exception object (e.g. it only has a typed fetch result); [category]
  /// wins when both are given. [phase] optionally tags which fetch phase
  /// failed (e.g. 'enrichment') as coarse metadata.
  static HealthSyncDiagnosticEvent fetchFailed({
    required HealthSyncDomain domain,
    Object? error,
    HealthSyncErrorCategory? category,
    String? phase,
    HealthSyncPlatform? platform,
  }) {
    assert(
      error != null || category != null,
      'fetchFailed requires an error to classify or a pre-classified category',
    );
    final resolved =
        category ??
        (error != null ? classify(error) : HealthSyncErrorCategory.unknown);
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchFailed,
      severity: HealthSyncDiagnosticSeverity.error,
      domain: domain,
      platform: platform,
      metadata: {
        'errorCategory': resolved.name,
        if (phase != null) 'phase': phase,
      },
    );
  }

  /// Builds a `fetchNoData` event: an informational, empty-metadata signal that
  /// a read succeeded but returned zero records.
  static HealthSyncDiagnosticEvent fetchNoData({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchNoData,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `fetchSucceeded` event carrying only the record [count].
  static HealthSyncDiagnosticEvent fetchSucceeded({
    required HealthSyncDomain domain,
    required int count,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchSucceeded,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {'count': count},
    );
  }

  /// Builds a `permissionDenied` event: a verified platform permission
  /// denial for [domain]. No metadata beyond the coarse fields.
  static HealthSyncDiagnosticEvent permissionDenied({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.permissionDenied,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `permissionFalseNegativeTolerated` event: the permission probe
  /// reported false but the guarded read succeeded, so the sync proceeded.
  /// Warning severity — worth watching in aggregate, not an error. Carries no
  /// metadata beyond the coarse fields.
  static HealthSyncDiagnosticEvent permissionFalseNegativeTolerated({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.permissionFalseNegativeTolerated,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `platformUnavailable` event: HealthKit / Health Connect is
  /// missing or unusable on this device. No metadata beyond coarse fields.
  static HealthSyncDiagnosticEvent platformUnavailable({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.platformUnavailable,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `sourceSelected` event carrying only counts and the coarse
  /// [selectedCategory] — never a raw source display name.
  static HealthSyncDiagnosticEvent sourceSelected({
    required HealthSyncDomain domain,
    required int sourceCount,
    required int discardedCount,
    required HealthSyncSourceCategory selectedCategory,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.sourceSelected,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {
        'sourceCount': sourceCount,
        'discardedCount': discardedCount,
        'selectedCategory': selectedCategory.name,
      },
    );
  }

  /// Builds a `duplicateDiscarded` event: ONE aggregated event per sync run
  /// when the workout deduplicator skipped anything (exact identity or
  /// strong fingerprint) or imported a suspected duplicate. Carries only the
  /// three counts — never workout IDs, raw source names, or timestamps.
  static HealthSyncDiagnosticEvent duplicateDiscarded({
    required HealthSyncDomain domain,
    required int exactCount,
    required int strongCount,
    required int suspectedImportedCount,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.duplicateDiscarded,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {
        'exactCount': exactCount,
        'strongCount': strongCount,
        'suspectedImportedCount': suspectedImportedCount,
      },
    );
  }

  /// Builds an `eventIdCollision` event: an imported workout's deterministic
  /// eventId was already occupied by an existing local sport event, so the
  /// activity was skipped instead of overwriting it (saveSportEvent would
  /// otherwise silently replace by eventId). Metadata carries only the coarse
  /// [sourceCategory] token (a HealthSourceCategory name) — never raw source
  /// names, event ids, or timestamps.
  static HealthSyncDiagnosticEvent eventIdCollision({
    required HealthSyncDomain domain,
    String? sourceCategory,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.eventIdCollision,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
      metadata: {
        if (sourceCategory != null) 'sourceCategory': sourceCategory,
      },
    );
  }

  /// Builds a `typeMappingFallback` event: an activity type with no specific
  /// mapping was imported under the configured generic sport. Info severity —
  /// the import succeeded deterministically; the event gives aggregate
  /// visibility into mapping-table gaps. [activityType] is the normalized
  /// platform activity-category token (e.g. 'TAI_CHI') — a coarse
  /// enum-derived value, never a raw source name, timestamp, or identifier.
  static HealthSyncDiagnosticEvent typeMappingFallback({
    required HealthSyncDomain domain,
    required String activityType,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.typeMappingFallback,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {'activityType': activityType},
    );
  }

  /// Builds a `typeMappingUnmapped` event: an activity type had no specific
  /// mapping AND the master file has no generic sport, so the activity was
  /// skipped (no import, no metadata write). Warning severity — a real
  /// workout was dropped by policy. Same coarse [activityType] metadata as
  /// [typeMappingFallback].
  static HealthSyncDiagnosticEvent typeMappingUnmapped({
    required HealthSyncDomain domain,
    required String activityType,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.typeMappingUnmapped,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
      metadata: {'activityType': activityType},
    );
  }

  /// Builds an `identityMissing` event: a warning that a day-bucketed record
  /// was saved locally but its upload was skipped because no user ID was
  /// available (profile absent or userId null/empty). Carries no metadata —
  /// never the record, the user, or any identifier.
  static HealthSyncDiagnosticEvent identityMissing({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.identityMissing,
      severity: HealthSyncDiagnosticSeverity.warning,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `syncStarted` event: a sync attempt has passed all skip-checks
  /// and is about to perform the guarded platform read. Debug severity — this
  /// fires on every non-skipped attempt and is a bookend marker only, no
  /// metadata.
  static HealthSyncDiagnosticEvent syncStarted({
    required HealthSyncDomain domain,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.syncStarted,
      severity: HealthSyncDiagnosticSeverity.debug,
      domain: domain,
      platform: platform,
    );
  }

  /// Builds a `syncSkipped` event: a sync attempt never reached the platform
  /// read because a precondition failed. [reason] is one of the
  /// skip-shaped [SyncHealthOutcome] values (`skippedDisabled`,
  /// `skippedThrottled`, `skippedPreconditions`) carried as a coarse metadata
  /// label — dropped from the production Crashlytics line by the sink's
  /// int/bool-only filter (D11), but retained on the event object for the
  /// in-memory sink and tests.
  static HealthSyncDiagnosticEvent syncSkipped({
    required HealthSyncDomain domain,
    required SyncHealthOutcome reason,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.syncSkipped,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {'reason': reason.name},
    );
  }

  /// Builds a `syncCompleted` event: a bookend fired on every terminal path
  /// once a sync attempt actually started (fetchFailed, permissionDenied,
  /// platformUnavailable, syncedNoData, synced, syncedPartial, error).
  /// Always info severity regardless of [outcome] — the paired
  /// outcome-specific event (already emitted alongside this one) carries the
  /// real warning/error severity, so this bookend doesn't duplicate it.
  static HealthSyncDiagnosticEvent syncCompleted({
    required HealthSyncDomain domain,
    required SyncHealthOutcome outcome,
    HealthSyncPlatform? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.syncCompleted,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {'outcome': outcome.name},
    );
  }

  /// Returns a `yyyy-MM-dd` day bucket, stripping all time-of-day precision.
  static String dayBucket(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Best-effort, deterministic classification of [error] into a coarse
  /// category. Inspects only a lowercase signature of the runtime type and
  /// `toString()` for matching; the signature itself is never stored.
  static HealthSyncErrorCategory classify(Object error) {
    if (error is TimeoutException) {
      return HealthSyncErrorCategory.timeout;
    }
    final signature = '${error.runtimeType} $error'.toLowerCase();
    // A literal exception-class-name match is a higher-confidence signal
    // than a generic English-word substring match, so it's checked before
    // the word-based categories below (order-sensitivity fix, T15).
    if (signature.contains('missingplugin') ||
        signature.contains('platformexception')) {
      // ...but a verified permission/denial word still outranks a bare
      // PlatformException wrapper — Health Connect delivers permission
      // denials AS a PlatformException, so check permission first.
      if (signature.contains('permission') ||
          signature.contains('unauthor') ||
          signature.contains('denied')) {
        return HealthSyncErrorCategory.permission;
      }
      return HealthSyncErrorCategory.plugin;
    }
    if (signature.contains('permission') ||
        signature.contains('unauthor') ||
        signature.contains('denied')) {
      return HealthSyncErrorCategory.permission;
    }
    if (signature.contains('unavailable') ||
        signature.contains('not available') ||
        signature.contains('not supported') ||
        signature.contains('unsupported')) {
      return HealthSyncErrorCategory.platformUnavailable;
    }
    if (signature.contains('timeout') || signature.contains('timed out')) {
      return HealthSyncErrorCategory.timeout;
    }
    if (signature.contains('socket') ||
        signature.contains('network') ||
        signature.contains('connection')) {
      return HealthSyncErrorCategory.network;
    }
    if (signature.contains('plugin')) {
      return HealthSyncErrorCategory.plugin;
    }
    return HealthSyncErrorCategory.unknown;
  }
}
