import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

abstract class Preferences {
  int getInt(PrefsKeys key);
  Future<void> setInt(PrefsKeys key, int value);
  String getString(PrefsKeys key);
  Future<void> setString(PrefsKeys key, String value);
  bool getBool(PrefsKeys key);
  Future<void> setBool(PrefsKeys key, bool value);
  bool? getBoolOrNull(PrefsKeys key);
}