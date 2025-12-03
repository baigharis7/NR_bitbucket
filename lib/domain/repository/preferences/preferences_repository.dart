import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

abstract class PreferencesRepository {
  Future<void> setSub(String sub);
  String getSub();
  Future<void> setUsername(String userName);
  String getUsername();
  Future<void> setEmail(String email);
  String getEmail();
  Future<void> setIdToken(String idToken);
  String getIdToken();
  Future<void> setAccessToken(String accessToken);
  String getAccessToken();
  Future<void> setRefreshToken(String refreshToken);
  String getRefreshToken();
  Future<void> setUserCredentials(CognitoAuthSession session);
  Future<void> setUsernameAndEmail(String username, String email);
  Future<void> setUserSignedIn(bool isSignedIn);
  Future<bool> isUserSignedIn();
  Future<void> saveLastFetchTime(PrefsKeys categoryType, DateTime time);
  Future<DateTime?> getLastFetchTime(PrefsKeys categoryType);
}