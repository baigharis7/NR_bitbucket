import 'dart:async';

import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';

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

/// Pure builders that assemble [HealthSyncDiagnosticEvent]s carrying only
/// privacy-safe fields: counts, coarse categories, coarse platform, and
/// day-bucketed dates. No Firebase, no raw health payloads.
class HealthSyncDiagnostics {
  const HealthSyncDiagnostics._();

  /// Builds a `fetchFailed` event. Only the classified [HealthSyncErrorCategory]
  /// is retained in metadata — never the raw message or stacktrace.
  static HealthSyncDiagnosticEvent fetchFailed({
    required HealthSyncDomain domain,
    required Object error,
    String? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchFailed,
      severity: HealthSyncDiagnosticSeverity.error,
      domain: domain,
      platform: platform,
      metadata: {'errorCategory': classify(error).name},
    );
  }

  /// Builds a `fetchNoData` event: an informational, empty-metadata signal that
  /// a read succeeded but returned zero records.
  static HealthSyncDiagnosticEvent fetchNoData({
    required HealthSyncDomain domain,
    String? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchNoData,
      severity: HealthSyncDiagnosticSeverity.info,
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
    required String selectedCategory,
    String? platform,
  }) {
    return HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.sourceSelected,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: domain,
      platform: platform,
      metadata: {
        'sourceCount': sourceCount,
        'discardedCount': discardedCount,
        'selectedCategory': selectedCategory,
      },
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
    if (signature.contains('platformexception') ||
        signature.contains('missingplugin') ||
        signature.contains('plugin')) {
      return HealthSyncErrorCategory.plugin;
    }
    return HealthSyncErrorCategory.unknown;
  }
}
