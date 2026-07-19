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

    test(
      'an exception-class-name signal (MissingPluginException) wins over '
      'a generic "unavailable" word in the same message',
      () {
        expect(
          HealthSyncDiagnostics.classify(
            Exception(
              'MissingPluginException: Health Connect is unavailable',
            ),
          ),
          HealthSyncErrorCategory.plugin,
        );
      },
    );

    test('permission still wins over an exception-class-name signal', () {
      expect(
        HealthSyncDiagnostics.classify(
          Exception('PlatformException: permission denied'),
        ),
        HealthSyncErrorCategory.permission,
      );
    });

    test('a bare "plugin"-worded error still classifies as plugin', () {
      expect(
        HealthSyncDiagnostics.classify(Exception('custom plugin failure')),
        HealthSyncErrorCategory.plugin,
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

    test('accepts a pre-classified category without an error object', () {
      final event = HealthSyncDiagnostics.fetchFailed(
        domain: HealthSyncDomain.workout,
        category: HealthSyncErrorCategory.timeout,
      );

      expect(event.type, HealthSyncDiagnosticType.fetchFailed);
      expect(event.severity, HealthSyncDiagnosticSeverity.error);
      expect(event.metadata['errorCategory'], 'timeout');
      expect(event.metadata.containsKey('phase'), isFalse);
    });

    test('an explicit category wins over classification of the error', () {
      final event = HealthSyncDiagnostics.fetchFailed(
        domain: HealthSyncDomain.workout,
        error: Exception('Permission denied'),
        category: HealthSyncErrorCategory.plugin,
      );

      expect(event.metadata['errorCategory'], 'plugin');
    });

    test('adds a phase metadata entry when phase is non-null', () {
      final event = HealthSyncDiagnostics.fetchFailed(
        domain: HealthSyncDomain.workout,
        category: HealthSyncErrorCategory.plugin,
        phase: 'enrichment',
      );

      expect(event.metadata['errorCategory'], 'plugin');
      expect(event.metadata['phase'], 'enrichment');
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

  group('HealthSyncDiagnostics.permissionFalseNegativeTolerated', () {
    test('is a warning-severity event with empty metadata', () {
      final event = HealthSyncDiagnostics.permissionFalseNegativeTolerated(
        domain: HealthSyncDomain.workout,
      );

      expect(
        event.type,
        HealthSyncDiagnosticType.permissionFalseNegativeTolerated,
      );
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, isEmpty);
    });

    test('carries a coarse platform when provided', () {
      final event = HealthSyncDiagnostics.permissionFalseNegativeTolerated(
        domain: HealthSyncDomain.workout,
        platform: HealthSyncPlatform.android,
      );
      expect(event.platform, HealthSyncPlatform.android);
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

  group('HealthSyncDiagnostics.duplicateDiscarded', () {
    test('is an info-severity event carrying only the three counts', () {
      final event = HealthSyncDiagnostics.duplicateDiscarded(
        domain: HealthSyncDomain.workout,
        exactCount: 2,
        strongCount: 1,
        suspectedImportedCount: 3,
      );

      expect(event.type, HealthSyncDiagnosticType.duplicateDiscarded);
      expect(event.severity, HealthSyncDiagnosticSeverity.info);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, {
        'exactCount': 2,
        'strongCount': 1,
        'suspectedImportedCount': 3,
      });
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

  group('HealthSyncDiagnostics.fetchSucceeded', () {
    test('is an info-severity event carrying only the count', () {
      final event = HealthSyncDiagnostics.fetchSucceeded(
        domain: HealthSyncDomain.workout,
        count: 3,
      );

      expect(event.type, HealthSyncDiagnosticType.fetchSucceeded);
      expect(event.severity, HealthSyncDiagnosticSeverity.info);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, {'count': 3});
    });
  });

  group('HealthSyncDiagnostics.permissionDenied', () {
    test('is a warning-severity event with empty metadata', () {
      final event = HealthSyncDiagnostics.permissionDenied(
        domain: HealthSyncDomain.workout,
      );

      expect(event.type, HealthSyncDiagnosticType.permissionDenied);
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.metadata, isEmpty);
    });
  });

  group('HealthSyncDiagnostics.platformUnavailable', () {
    test('is a warning-severity event with empty metadata', () {
      final event = HealthSyncDiagnostics.platformUnavailable(
        domain: HealthSyncDomain.workout,
      );

      expect(event.type, HealthSyncDiagnosticType.platformUnavailable);
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.metadata, isEmpty);
    });
  });

  group('HealthSyncDiagnostics.eventIdCollision', () {
    test('is a warning-severity event with empty metadata by default', () {
      final event = HealthSyncDiagnostics.eventIdCollision(
        domain: HealthSyncDomain.workout,
      );

      expect(event.type, HealthSyncDiagnosticType.eventIdCollision);
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, isEmpty);
    });

    test('carries only the coarse source category when provided', () {
      final event = HealthSyncDiagnostics.eventIdCollision(
        domain: HealthSyncDomain.workout,
        sourceCategory: 'appleWatch',
      );

      expect(event.metadata, {'sourceCategory': 'appleWatch'});
    });
  });

  group('HealthSyncDiagnostics.typeMappingFallback', () {
    test('is an info-severity event carrying only the coarse activity type',
        () {
      final event = HealthSyncDiagnostics.typeMappingFallback(
        domain: HealthSyncDomain.workout,
        activityType: 'TAI_CHI',
      );

      expect(event.type, HealthSyncDiagnosticType.typeMappingFallback);
      expect(event.severity, HealthSyncDiagnosticSeverity.info);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, {'activityType': 'TAI_CHI'});
    });
  });

  group('HealthSyncDiagnostics.typeMappingUnmapped', () {
    test('is a warning-severity event carrying only the coarse activity type',
        () {
      final event = HealthSyncDiagnostics.typeMappingUnmapped(
        domain: HealthSyncDomain.workout,
        activityType: 'TAI_CHI',
      );

      expect(event.type, HealthSyncDiagnosticType.typeMappingUnmapped);
      expect(event.severity, HealthSyncDiagnosticSeverity.warning);
      expect(event.domain, HealthSyncDomain.workout);
      expect(event.platform, isNull);
      expect(event.metadata, {'activityType': 'TAI_CHI'});
    });
  });
}
