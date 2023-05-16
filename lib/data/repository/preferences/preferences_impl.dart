import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesImpl extends Preferences {
  final SharedPreferences prefs;

  PreferencesImpl(this.prefs);

  @override
  int getInt(PrefsKeys key) => prefs.getInt(key.name) ?? 0;

  @override
  String getString(PrefsKeys key) => prefs.getString(key.name) ?? '';

  @override
  Future<void> setInt(PrefsKeys key, int value) => prefs.setInt(key.name, value);

  @override
  Future<void> setString(PrefsKeys key, String value) => prefs.setString(key.name, value);

  @override
  bool getBool(PrefsKeys key) => prefs.getBool(key.name) ?? false;

  @override
  Future<void> setBool(PrefsKeys key, bool value) => prefs.setBool(key.name, value);

}