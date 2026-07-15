import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_client.dart';

class MockHealth extends Mock implements Health {}

void main() {
  setUpAll(() {
    registerFallbackValue(<HealthDataType>[]);
    registerFallbackValue(<HealthDataAccess>[]);
  });

  late MockHealth health;

  setUp(() {
    health = MockHealth();
  });

  test('does not create Health until first op, then reuses one instance', () async {
    var created = 0;
    final client = HealthPlatformClientImpl(healthFactory: () {
      created++;
      return health;
    });
    expect(created, 0);

    when(() => health.hasPermissions(any(), permissions: any(named: 'permissions')))
        .thenAnswer((_) async => true);

    await client.hasPermissions([HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ]);
    await client.hasPermissions([HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ]);
    expect(created, 1);
  });

  test('requestAuthorization delegates args and result unchanged', () async {
    final client = HealthPlatformClientImpl(healthFactory: () => health);
    when(() => health.requestAuthorization(any(),
        permissions: any(named: 'permissions'))).thenAnswer((_) async => true);

    final types = [HealthDataType.WORKOUT, HealthDataType.STEPS];
    final perms = [HealthDataAccess.READ, HealthDataAccess.READ];
    final result = await client.requestAuthorization(types, permissions: perms);

    expect(result, isTrue);
    final captured = verify(() => health.requestAuthorization(
        captureAny(),
        permissions: captureAny(named: 'permissions'))).captured;
    expect(captured[0], types);
    expect(captured[1], perms);
  });

  test('hasPermissions delegates and preserves a null result', () async {
    final client = HealthPlatformClientImpl(healthFactory: () => health);
    when(() => health.hasPermissions(any(), permissions: any(named: 'permissions')))
        .thenAnswer((_) async => null);

    final result = await client.hasPermissions([HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ]);
    expect(result, isNull);
  });

  test('getHealthDataFromTypes delegates types + range and returns points', () async {
    final client = HealthPlatformClientImpl(healthFactory: () => health);
    final start = DateTime(2026, 7, 1);
    final end = DateTime(2026, 7, 2);
    final points = <HealthDataPoint>[];
    when(() => health.getHealthDataFromTypes(
          types: any(named: 'types'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
        )).thenAnswer((_) async => points);

    final result = await client.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT], startTime: start, endTime: end);

    expect(result, same(points));
    final captured = verify(() => health.getHealthDataFromTypes(
          types: captureAny(named: 'types'),
          startTime: captureAny(named: 'startTime'),
          endTime: captureAny(named: 'endTime'),
        )).captured;
    expect(captured[0], [HealthDataType.WORKOUT]);
    expect(captured[1], start);
    expect(captured[2], end);
  });

  test('plugin exceptions propagate to the caller', () async {
    final client = HealthPlatformClientImpl(healthFactory: () => health);
    when(() => health.getHealthDataFromTypes(
          types: any(named: 'types'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
        )).thenThrow(Exception('boom'));

    expect(
      () => client.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: DateTime(2026),
          endTime: DateTime(2026)),
      throwsException,
    );
  });
}
