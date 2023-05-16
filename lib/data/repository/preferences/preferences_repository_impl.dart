import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class PreferencesRepositoryImpl extends PreferencesRepository {
  final Preferences prefs;

  PreferencesRepositoryImpl({required this.prefs});

  @override
  String getSub() => prefs.getString(PrefsKeys.sub);

  @override
  Future<void> setSub(String sub) async => prefs.setString(PrefsKeys.sub, sub);

  @override
  String getUsername() => prefs.getString(PrefsKeys.username);

  @override
  Future<void> setUsername(String userName) async => prefs.setString(PrefsKeys.username, userName);

  @override
  String getEmail() => prefs.getString(PrefsKeys.email);

  @override
  Future<void> setEmail(String email) async => prefs.setString(PrefsKeys.email, email);

  @override
  String getAccessToken() => prefs.getString(PrefsKeys.accessToken);

  @override
  Future<void> setAccessToken(String accessToken) async => prefs.setString(PrefsKeys.accessToken, accessToken);

  @override
  String getIdToken() => prefs.getString(PrefsKeys.idToken);

  @override
  Future<void> setIdToken(String idToken) async => prefs.setString(PrefsKeys.idToken, idToken);

  @override
  String getRefreshToken() => prefs.getString(PrefsKeys.refreshToken);

  @override
  Future<void> setRefreshToken(String refreshToken) async => prefs.setString(PrefsKeys.refreshToken, refreshToken);

  @override
  Future<void> setUserCredentials(CognitoAuthSession session) async {
    setSub(session.userSub.orEmpty());
    setIdToken(session.userPoolTokens!.idToken.orEmpty());
    setAccessToken(session.userPoolTokens!.accessToken.orEmpty());
    setRefreshToken(session.userPoolTokens!.refreshToken.orEmpty());
    setUserSignedIn(session.isSignedIn);
  }

  @override
  Future<void> setUsernameAndEmail(String username, String email) async {
    setUsername(username);
    setEmail(email);
  }

  @override
  Future<bool> isUserSignedIn() async => prefs.getBool(PrefsKeys.isUserSignedIn);

  @override
  Future<void> setUserSignedIn(bool isSignedIn) async => prefs.setBool(PrefsKeys.isUserSignedIn, isSignedIn);

}