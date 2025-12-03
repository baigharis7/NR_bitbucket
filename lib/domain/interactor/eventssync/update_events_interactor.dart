import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

abstract class UpdateEventsInteractor {
  Future<bool> execute({required String userId, required PrefsKeys categoryType, required bool fullSync});
}