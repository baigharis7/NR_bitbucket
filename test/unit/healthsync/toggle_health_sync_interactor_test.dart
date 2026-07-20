import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor_impl.dart';

import '../../mocks/health_sync_mocks.dart';

/// T6 (Option A): the toggle interactor owns only availability/permission
/// checks and the enabled pref — it must not schedule any background work.
/// These tests run with no plugin bindings at all, so any surviving
/// WorkManager call would throw and surface as a `false` return.
void main() {
  late MockHealthSyncRepository repository;
  late ToggleHealthSyncInteractorImpl interactor;

  setUp(() {
    repository = MockHealthSyncRepository();
    interactor =
        ToggleHealthSyncInteractorImpl(healthSyncRepository: repository);
  });

  group('enable', () {
    test('enables the pref and returns true when available with permissions',
        () async {
      when(() => repository.isHealthSyncAvailable())
          .thenAnswer((_) async => true);
      when(() => repository.hasPermissions()).thenAnswer((_) async => true);
      when(() => repository.setHealthSyncEnabled(true))
          .thenAnswer((_) async {});

      final result = await interactor.execute(true);

      expect(result, isTrue);
      verify(() => repository.setHealthSyncEnabled(true)).called(1);
    });

    test('returns false without writing the pref when platform unavailable',
        () async {
      when(() => repository.isHealthSyncAvailable())
          .thenAnswer((_) async => false);

      final result = await interactor.execute(true);

      expect(result, isFalse);
      verifyNever(() => repository.setHealthSyncEnabled(any()));
    });

    test('requests permissions when missing and enables on grant', () async {
      when(() => repository.isHealthSyncAvailable())
          .thenAnswer((_) async => true);
      when(() => repository.hasPermissions()).thenAnswer((_) async => false);
      when(() => repository.requestPermissions()).thenAnswer((_) async => true);
      when(() => repository.setHealthSyncEnabled(true))
          .thenAnswer((_) async {});

      final result = await interactor.execute(true);

      expect(result, isTrue);
      verify(() => repository.requestPermissions()).called(1);
      verify(() => repository.setHealthSyncEnabled(true)).called(1);
    });

    test('returns false without writing the pref when permissions are refused',
        () async {
      when(() => repository.isHealthSyncAvailable())
          .thenAnswer((_) async => true);
      when(() => repository.hasPermissions()).thenAnswer((_) async => false);
      when(() => repository.requestPermissions())
          .thenAnswer((_) async => false);

      final result = await interactor.execute(true);

      expect(result, isFalse);
      verifyNever(() => repository.setHealthSyncEnabled(any()));
    });
  });

  group('disable', () {
    test('disables the pref and returns true', () async {
      when(() => repository.setHealthSyncEnabled(false))
          .thenAnswer((_) async {});

      final result = await interactor.execute(false);

      expect(result, isTrue);
      verify(() => repository.setHealthSyncEnabled(false)).called(1);
    });
  });

  test('returns false when the repository throws', () async {
    when(() => repository.isHealthSyncAvailable())
        .thenThrow(Exception('platform channel down'));

    final result = await interactor.execute(true);

    expect(result, isFalse);
  });
}
