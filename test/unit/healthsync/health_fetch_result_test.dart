import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';

void main() {
  group('HealthFetchResult factories', () {
    test('success carries data and success status', () {
      const result = HealthFetchResult<List<int>>.success([1, 2, 3]);
      expect(result.status, HealthFetchStatus.success);
      expect(result.data, [1, 2, 3]);
      expect(result.failureReason, isNull);
      expect(result.failureMessage, isNull);
    });

    test(
      'successNoData carries the empty payload and successNoData status',
      () {
        const result = HealthFetchResult<List<int>>.successNoData([]);
        expect(result.status, HealthFetchStatus.successNoData);
        expect(result.data, isEmpty);
        expect(result.failureReason, isNull);
        expect(result.failureMessage, isNull);
      },
    );

    test('permissionDenied sets status, permission reason, and message', () {
      const result = HealthFetchResult<List<int>>.permissionDenied(
        message: 'denied',
      );
      expect(result.status, HealthFetchStatus.permissionDenied);
      expect(result.data, isNull);
      expect(result.failureReason, HealthFetchFailureReason.permission);
      expect(result.failureMessage, 'denied');
    });

    test('platformUnavailable sets status, reason, and message', () {
      const result = HealthFetchResult<List<int>>.platformUnavailable(
        message: 'no HealthKit',
      );
      expect(result.status, HealthFetchStatus.platformUnavailable);
      expect(result.data, isNull);
      expect(
        result.failureReason,
        HealthFetchFailureReason.platformUnavailable,
      );
      expect(result.failureMessage, 'no HealthKit');
    });

    test('failed defaults to the unknown reason', () {
      const result = HealthFetchResult<List<int>>.failed();
      expect(result.status, HealthFetchStatus.failed);
      expect(result.data, isNull);
      expect(result.failureReason, HealthFetchFailureReason.unknown);
      expect(result.failureMessage, isNull);
    });

    test('failed carries an explicit reason and message', () {
      const result = HealthFetchResult<List<int>>.failed(
        reason: HealthFetchFailureReason.pluginError,
        message: 'boom',
      );
      expect(result.status, HealthFetchStatus.failed);
      expect(result.failureReason, HealthFetchFailureReason.pluginError);
      expect(result.failureMessage, 'boom');
    });

    test('partialSuccess carries data plus optional reason and message', () {
      const result = HealthFetchResult<List<int>>.partialSuccess(
        [1],
        reason: HealthFetchFailureReason.pluginError,
        message: 'enrichment failed',
      );
      expect(result.status, HealthFetchStatus.partialSuccess);
      expect(result.data, [1]);
      expect(result.failureReason, HealthFetchFailureReason.pluginError);
      expect(result.failureMessage, 'enrichment failed');
    });
  });

  group('isSuccess', () {
    test('is true for success and successNoData', () {
      expect(const HealthFetchResult<List<int>>.success([1]).isSuccess, isTrue);
      expect(
        const HealthFetchResult<List<int>>.successNoData([]).isSuccess,
        isTrue,
      );
    });

    test('is false for permission, platform, failed, and partial statuses', () {
      expect(
        const HealthFetchResult<List<int>>.permissionDenied().isSuccess,
        isFalse,
      );
      expect(
        const HealthFetchResult<List<int>>.platformUnavailable().isSuccess,
        isFalse,
      );
      expect(const HealthFetchResult<List<int>>.failed().isSuccess, isFalse);
      expect(
        const HealthFetchResult<List<int>>.partialSuccess([1]).isSuccess,
        isFalse,
      );
    });
  });

  group('hasData', () {
    test('is true for a non-empty list payload', () {
      expect(const HealthFetchResult<List<int>>.success([1]).hasData, isTrue);
    });

    test('is false for an empty list payload', () {
      expect(
        const HealthFetchResult<List<int>>.successNoData([]).hasData,
        isFalse,
      );
    });

    test('is false for a failed result with no data', () {
      expect(const HealthFetchResult<List<int>>.failed().hasData, isFalse);
    });
  });
}
