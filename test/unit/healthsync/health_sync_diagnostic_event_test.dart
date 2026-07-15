import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';

void main() {
  test('constructs an event exposing every field', () {
    const event = HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.fetchSucceeded,
      severity: HealthSyncDiagnosticSeverity.info,
      domain: HealthSyncDomain.workout,
      platform: 'android',
      metadata: {'count': 3},
    );

    expect(event.type, HealthSyncDiagnosticType.fetchSucceeded);
    expect(event.severity, HealthSyncDiagnosticSeverity.info);
    expect(event.domain, HealthSyncDomain.workout);
    expect(event.platform, 'android');
    expect(event.metadata['count'], 3);
  });

  test('defaults platform to null and metadata to an empty const map', () {
    const event = HealthSyncDiagnosticEvent(
      type: HealthSyncDiagnosticType.syncStarted,
      severity: HealthSyncDiagnosticSeverity.debug,
      domain: HealthSyncDomain.background,
    );

    expect(event.platform, isNull);
    expect(event.metadata, isEmpty);
    // Default is a canonical const empty map (const-canonicalization → identical instance).
    expect(event.metadata, same(const <String, Object>{}));
  });
}
