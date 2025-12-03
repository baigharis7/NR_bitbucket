import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

abstract class EventsSynchronizationRequestRepository {
  Future<bool> synchronizeEvents(String userId, {required bool fullSync});
  Future<bool> fetchEvents(String userId, PrefsKeys categoryType, {required bool fullSync});
}
