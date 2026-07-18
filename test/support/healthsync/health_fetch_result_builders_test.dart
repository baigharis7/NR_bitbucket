import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';

import 'health_activity_builder.dart';
import 'health_fetch_result_builders.dart';

void main() {
  group('HealthFetchResult builders', () {
    test('successResult wraps activities with success status', () {
      final activities = [aHealthActivity()];
      final r = successResult(activities);
      expect(r.status, HealthFetchStatus.success);
      expect(r.data, same(activities));
      expect(r.isSuccess, isTrue);
      expect(r.hasData, isTrue);
    });

    test('noDataResult is successNoData with empty data', () {
      final r = noDataResult();
      expect(r.status, HealthFetchStatus.successNoData);
      expect(r.data, isEmpty);
      expect(r.isSuccess, isTrue);
      expect(r.hasData, isFalse);
    });

    test('failedResult carries failed status and a reason', () {
      final r = failedResult();
      expect(r.status, HealthFetchStatus.failed);
      expect(r.failureReason, HealthFetchFailureReason.pluginError);
      expect(r.isSuccess, isFalse);
    });

    test('permissionDeniedResult carries permissionDenied status', () {
      final r = permissionDeniedResult();
      expect(r.status, HealthFetchStatus.permissionDenied);
      expect(r.isSuccess, isFalse);
    });

    test('platformUnavailableResult carries platformUnavailable status', () {
      final r = platformUnavailableResult();
      expect(r.status, HealthFetchStatus.platformUnavailable);
      expect(r.isSuccess, isFalse);
    });

    test('partialSuccessResult carries partialSuccess status and data', () {
      final activities = [aHealthActivity()];
      final r = partialSuccessResult(activities);
      expect(r.status, HealthFetchStatus.partialSuccess);
      expect(r.data, same(activities));
    });
  });
}
