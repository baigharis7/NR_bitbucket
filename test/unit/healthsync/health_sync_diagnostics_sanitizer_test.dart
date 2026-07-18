import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';

void main() {
  group('HealthSyncDiagnostics.classify', () {
    test('maps a TimeoutException to timeout', () {
      expect(
        HealthSyncDiagnostics.classify(TimeoutException('slow')),
        HealthSyncErrorCategory.timeout,
      );
    });

    test('maps a permission-worded error to permission', () {
      expect(
        HealthSyncDiagnostics.classify(Exception('Permission denied')),
        HealthSyncErrorCategory.permission,
      );
    });

    test('maps an unavailable-worded error to platformUnavailable', () {
      expect(
        HealthSyncDiagnostics.classify(
          Exception('Health Connect is unavailable'),
        ),
        HealthSyncErrorCategory.platformUnavailable,
      );
    });

    test('falls back to unknown for an unrecognized error', () {
      expect(
        HealthSyncDiagnostics.classify(Exception('boom')),
        HealthSyncErrorCategory.unknown,
      );
    });
  });

  group('HealthSyncDiagnostics.dayBucket', () {
    test('strips time-of-day to yyyy-MM-dd', () {
      final bucket = HealthSyncDiagnostics.dayBucket(
        DateTime(2026, 7, 15, 8, 30, 45),
      );
      expect(bucket, '2026-07-15');
      expect(bucket.contains(':'), isFalse);
    });
  });

  group('HealthSyncDiagnostics.fetchFailed', () {
    test('retains only the error category, never the raw message', () {
      final error = Exception(
        "Permission denied for source John's Apple Watch at "
        '2026-07-15T08:30:00.000Z user=user-42',
      );

      final event = HealthSyncDiagnostics.fetchFailed(
        domain: HealthSyncDomain.workout,
        platform: HealthSyncPlatform.ios,
        error: error,
      );

      expect(event.type, HealthSyncDiagnosticType.fetchFailed);
      expect(event.severity, HealthSyncDiagnosticSeverity.error);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, HealthSyncPlatform.ios);
      expect(
        event.metadata['errorCategory'],
        HealthSyncErrorCategory.permission.name,
      );

      // Privacy: no fragment of the raw message survives into metadata.
      final serialized = event.metadata.values
          .map((v) => v.toString())
          .join(' ');
      expect(serialized, isNot(contains("John's Apple Watch")));
      expect(serialized, isNot(contains('2026-07-15T08:30')));
      expect(serialized, isNot(contains('user-42')));
    });
  });

  group('HealthSyncDiagnostics.fetchNoData', () {
    test('is an info-severity event with empty metadata', () {
      final event = HealthSyncDiagnostics.fetchNoData(
        domain: HealthSyncDomain.steps,
        platform: HealthSyncPlatform.android,
      );
      expect(event.type, HealthSyncDiagnosticType.fetchNoData);
      expect(event.severity, HealthSyncDiagnosticSeverity.info);
      expect(event.domain, HealthSyncDomain.steps);
      expect(event.metadata, isEmpty);
    });
  });

  group('HealthSyncDiagnostics.sourceSelected', () {
    test('carries only counts and the selected category', () {
      final event = HealthSyncDiagnostics.sourceSelected(
        domain: HealthSyncDomain.sleep,
        platform: HealthSyncPlatform.android,
        sourceCount: 3,
        discardedCount: 2,
        selectedCategory: HealthSyncSourceCategory.wearable,
      );

      expect(event.type, HealthSyncDiagnosticType.sourceSelected);
      expect(event.metadata['sourceCount'], 3);
      expect(event.metadata['discardedCount'], 2);
      expect(event.metadata['selectedCategory'], 'wearable');
      // The builder exposes no parameter for a raw source name.
      expect(event.metadata.containsKey('sourceName'), isFalse);
    });
  });

  group('HealthSyncDiagnostics.identityMissing', () {
    test('is a warning-severity event with empty metadata', () {
      final event = HealthSyncDiagnostics.identityMissing(
        domain: HealthSyncDomain.sleep,
      );
      expect(event.type, HealthSyncDiagnosticType.identityMissing);
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.sleep);
      expect(event.platform, isNull);
      // Privacy: the builder exposes no way to attach a record, a user
      // identifier, or any other payload.
      expect(event.metadata, isEmpty);
    });

    test('carries the coarse platform when provided', () {
      final event = HealthSyncDiagnostics.identityMissing(
        domain: HealthSyncDomain.steps,
        platform: HealthSyncPlatform.android,
      );
      expect(event.domain, HealthSyncDomain.steps);
      expect(event.platform, HealthSyncPlatform.android);
      expect(event.metadata, isEmpty);
    });
  });
}
