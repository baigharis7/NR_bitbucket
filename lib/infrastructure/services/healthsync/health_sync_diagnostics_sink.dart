import 'dart:async';

import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

/// A destination for privacy-safe health-sync diagnostic events.
abstract class HealthSyncDiagnosticsSink {
  void add(HealthSyncDiagnosticEvent event);
}

/// Default sink: discards every event. Used until a real sink is wired in a
/// later ticket.
class NoopHealthSyncDiagnosticsSink implements HealthSyncDiagnosticsSink {
  const NoopHealthSyncDiagnosticsSink();

  @override
  void add(HealthSyncDiagnosticEvent event) {}
}

/// Test sink: accumulates events in insertion order.
class InMemoryHealthSyncDiagnosticsSink implements HealthSyncDiagnosticsSink {
  final List<HealthSyncDiagnosticEvent> events = [];

  @override
  void add(HealthSyncDiagnosticEvent event) => events.add(event);
}

/// Production-capable sink: serializes an already-sanitized event to a compact
/// one-line string and logs it to Crashlytics fire-and-forget. It emits only
/// the sanitized fields carried on the event — never a raw payload.
class CrashlyticsHealthSyncDiagnosticsSink
    implements HealthSyncDiagnosticsSink {
  const CrashlyticsHealthSyncDiagnosticsSink();

  @override
  void add(HealthSyncDiagnosticEvent event) {
    // `add` is void but CrashlyticsService.log is Future<void>; fire-and-forget.
    // CrashlyticsService.log internally swallows errors when Firebase is absent.
    unawaited(CrashlyticsService.instance.log(format(event)));
  }

  /// Builds the compact one-line representation logged to Crashlytics.
  /// Metadata keys are sorted for deterministic output. D11: only `int`- or
  /// `bool`-valued metadata entries are serialized — `String`-valued entries
  /// (coarse category/token labels like errorCategory, selectedCategory,
  /// sourceCategory, activityType, reason, outcome) are dropped here, even
  /// though they're already privacy-safe on the event object itself. This
  /// keeps the in-memory/test sink and any future debug export at full
  /// detail while restricting what actually reaches the third-party
  /// Crashlytics service to numeric/boolean signal.
  static String format(HealthSyncDiagnosticEvent event) {
    final buffer = StringBuffer('HealthSyncDiagnostic')
      ..write(' type=${event.type.name}')
      ..write(' severity=${event.severity.name}')
      ..write(' domain=${event.domain.name}')
      ..write(' platform=${event.platform?.name ?? 'unknown'}');
    final keys = event.metadata.keys
        .where((k) {
          final value = event.metadata[k];
          return value is int || value is bool;
        })
        .toList()
      ..sort();
    for (final key in keys) {
      buffer.write(' $key=${event.metadata[key]}');
    }
    return buffer.toString();
  }
}
