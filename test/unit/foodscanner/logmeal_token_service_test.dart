import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_token_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_token_service.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';

class MockPreferencesRepository extends Mock implements PreferencesRepository {}

class MockLogMealTokenApi extends Mock implements LogMealTokenApi {}

void main() {
  late MockPreferencesRepository mockPrefs;
  late MockLogMealTokenApi mockApi;
  late LogMealTokenService service;

  setUp(() {
    mockPrefs = MockPreferencesRepository();
    mockApi = MockLogMealTokenApi();
    service = LogMealTokenService(prefs: mockPrefs, api: mockApi);
  });

  group('LogMealTokenService', () {
    test('returns cached token from SharedPreferences', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('cached-token-123');

      final token = await service.getOrCreateToken();

      expect(token, 'cached-token-123');
      verifyNever(() => mockApi.getOrCreateToken(any()));
    });

    test('fetches token from backend when cache is empty', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('');
      when(() => mockPrefs.getSub()).thenReturn('user-id-abc');
      when(() => mockApi.getOrCreateToken('user-id-abc'))
          .thenAnswer((_) async => {'token': 'new-token-456'});
      when(() => mockPrefs.setLogMealToken('new-token-456'))
          .thenAnswer((_) async {});

      final token = await service.getOrCreateToken();

      expect(token, 'new-token-456');
      verify(() => mockApi.getOrCreateToken('user-id-abc')).called(1);
      verify(() => mockPrefs.setLogMealToken('new-token-456')).called(1);
    });

    test('returns null when userId is empty', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('');
      when(() => mockPrefs.getSub()).thenReturn('');

      final token = await service.getOrCreateToken();

      expect(token, isNull);
      verifyNever(() => mockApi.getOrCreateToken(any()));
    });

    test('returns null when backend returns no token', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('');
      when(() => mockPrefs.getSub()).thenReturn('user-id-abc');
      when(() => mockApi.getOrCreateToken('user-id-abc'))
          .thenAnswer((_) async => {'msg': 'error'});

      final token = await service.getOrCreateToken();

      expect(token, isNull);
      verifyNever(() => mockPrefs.setLogMealToken(any()));
    });

    test('returns null when backend throws exception', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('');
      when(() => mockPrefs.getSub()).thenReturn('user-id-abc');
      when(() => mockApi.getOrCreateToken('user-id-abc'))
          .thenThrow(Exception('Network error'));

      final token = await service.getOrCreateToken();

      expect(token, isNull);
    });

    test('does not cache empty token from backend', () async {
      when(() => mockPrefs.getLogMealToken()).thenReturn('');
      when(() => mockPrefs.getSub()).thenReturn('user-id-abc');
      when(() => mockApi.getOrCreateToken('user-id-abc'))
          .thenAnswer((_) async => {'token': ''});

      final token = await service.getOrCreateToken();

      expect(token, isNull);
      verifyNever(() => mockPrefs.setLogMealToken(any()));
    });

    test('clearToken sets empty string in prefs', () async {
      when(() => mockPrefs.setLogMealToken('')).thenAnswer((_) async {});

      await service.clearToken();

      verify(() => mockPrefs.setLogMealToken('')).called(1);
    });
  });
}
