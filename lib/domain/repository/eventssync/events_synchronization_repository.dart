import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

abstract class EventsSynchronizationRequestRepository {
  Future<bool> synchronizeEvents(String userId, {required bool fullSync, bool forceSync = false});
  Future<bool> fetchEvents(String userId, PrefsKeys categoryType, {required bool fullSync});
}
