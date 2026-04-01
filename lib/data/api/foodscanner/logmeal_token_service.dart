import 'package:flutter/foundation.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_token_api.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

/// Manages per-user LogMeal API tokens.
///
/// On first food scanner use, calls the backend Lambda to create a LogMeal
/// APIUser and obtain a per-user token. Caches the token in SharedPreferences
/// so subsequent uses don't require a network call.
class LogMealTokenService {
  final PreferencesRepository _prefs;
  final LogMealTokenApi _api;

  LogMealTokenService({
    required PreferencesRepository prefs,
    required LogMealTokenApi api,
  })  : _prefs = prefs,
        _api = api;

  /// Returns the per-user LogMeal token, fetching from backend if not cached.
  Future<String?> getOrCreateToken() async {
    // 1. Check local cache
    final cached = _prefs.getLogMealToken();
    if (cached.isNotEmpty) {
      debugPrint('[LogMealToken] Using cached token');
      return cached;
    }

    // 2. Fetch from backend (creates LogMeal user if needed)
    try {
      final userId = _prefs.getSub();
      if (userId.isEmpty) {
        debugPrint('[LogMealToken] No userId available');
        return null;
      }

      debugPrint('[LogMealToken] Fetching token from backend for user $userId');
      final response = await _api.getOrCreateToken(userId);
      final token = response['token'] as String?;

      if (token != null && token.isNotEmpty) {
        await _prefs.setLogMealToken(token);
        debugPrint('[LogMealToken] Token cached successfully');
        return token;
      }

      debugPrint('[LogMealToken] Backend returned no token');
      return null;
    } catch (e) {
      debugPrint('[LogMealToken] Error fetching token: $e');
      try {
        CrashlyticsService.instance.log('LogMeal token fetch failed: $e');
        await CrashlyticsService.instance.recordError(e, StackTrace.current);
      } catch (_) {
        // Crashlytics not initialized (e.g. in tests)
      }
      return null;
    }
  }

  /// Clears the cached token (call on logout).
  Future<void> clearToken() async {
    await _prefs.setLogMealToken('');
  }
}
