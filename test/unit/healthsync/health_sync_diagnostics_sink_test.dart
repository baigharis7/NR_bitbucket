import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';

HealthSyncDiagnosticEvent _event() => const HealthSyncDiagnosticEvent(
  type: HealthSyncDiagnosticType.fetchFailed,
  severity: HealthSyncDiagnosticSeverity.error,
  domain: HealthSyncDomain.workout,
  platform: HealthSyncPlatform.ios,
  metadata: {'errorCategory': 'permission'},
);

void main() {
  test('NoopHealthSyncDiagnosticsSink.add is a no-op and does not throw', () {
    const sink = NoopHealthSyncDiagnosticsSink();
    expect(() => sink.add(_event()), returnsNormally);
  });

  test('InMemoryHealthSyncDiagnosticsSink accumulates events in order', () {
    final sink = InMemoryHealthSyncDiagnosticsSink();
    final first = _event();
    const second = HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchNoData,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: HealthSyncDomain.steps,
    );

    sink.add(first);
    sink.add(second);

    expect(sink.events, [first, second]);
  });

  group('CrashlyticsHealthSyncDiagnosticsSink', () {
    test('formats a compact sanitized line with sorted metadata', () {
      final line = CrashlyticsHealthSyncDiagnosticsSink.format(
        const HealthSyncDiagnosticEvent(
          type: HealthSyncDiagnosticType.sourceSelected,
          severity: HealthSyncDiagnosticSeverity.info,
          domain: HealthSyncDomain.sleep,
          platform: HealthSyncPlatform.android,
          metadata: {'sourceCount': 3, 'discardedCount': 2},
        ),
      );

      expect(
        line,
        'HealthSyncDiagnostic type=sourceSelected severity=info '
        'domain=sleep platform=android discardedCount=2 sourceCount=3',
      );
    });

    test('drops String-valued metadata but keeps int/bool metadata', () {
      final line = CrashlyticsHealthSyncDiagnosticsSink.format(
        const HealthSyncDiagnosticEvent(
          type: HealthSyncDiagnosticType.fetchFailed,
          severity: HealthSyncDiagnosticSeverity.error,
          domain: HealthSyncDomain.workout,
          platform: HealthSyncPlatform.android,
          metadata: {
            'errorCategory': 'permission', // String — must be dropped
            'retryCount': 2, // int — must be kept
            'isRetryable': true, // bool — must be kept
          },
        ),
      );

      expect(line, isNot(contains('errorCategory')));
      expect(line, isNot(contains('permission')));
      expect(line, contains('retryCount=2'));
      expect(line, contains('isRetryable=true'));
    });

    test('add does not throw when Firebase is absent', () {
      const sink = CrashlyticsHealthSyncDiagnosticsSink();
      expect(() => sink.add(_event()), returnsNormally);
    });
  });
}
