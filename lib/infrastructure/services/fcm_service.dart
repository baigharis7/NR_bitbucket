import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

class FcmService {
  FcmService._privateConstructor();
  static final FcmService instance = FcmService._privateConstructor();

  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onDataMessage => _messageController.stream;
  String? _token;
  String? get token => _token;
  @visibleForTesting
  set tokenForTesting(String? value) => _token = value;
  @visibleForTesting
  void simulateMessage(RemoteMessage message) => _messageController.add(message);

  GetUserIdInteractor? _getUserIdInteractor;
  UpdateEventsInteractor? _updateEventsInteractor;
  SynchronizeEventsInteractor? _synchronizeEventsInteractor;
  StreamSubscription<RemoteMessage>? _syncSubscription;

  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _token = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _onTokenRefreshCallback?.call(newToken);
    });

    FirebaseMessaging.onMessage.listen((message) {
      _messageController.add(message);
    });
  }

  void configureSyncHandler({
    required GetUserIdInteractor getUserIdInteractor,
    required UpdateEventsInteractor updateEventsInteractor,
    required SynchronizeEventsInteractor synchronizeEventsInteractor,
  }) {
    _getUserIdInteractor = getUserIdInteractor;
    _updateEventsInteractor = updateEventsInteractor;
    _synchronizeEventsInteractor = synchronizeEventsInteractor;

    _syncSubscription?.cancel();
    _syncSubscription = onDataMessage.listen(_handleFcmSync);
  }

  Future<void> _handleFcmSync(RemoteMessage message) async {
    try {
      final userId = _getUserIdInteractor?.execute() ?? '';
      if (userId.isEmpty) return;

      final category = message.data['category'] as String?;
      final prefsKey = _categoryToPrefsKey(category);
      if (prefsKey != null) {
        await _updateEventsInteractor?.execute(userId: userId, categoryType: prefsKey, fullSync: false);
      } else {
        await _synchronizeEventsInteractor?.execute(userId, fullSync: false);
      }

      final busCategory = _categoryToBusCategory(category);
      if (busCategory != null) {
        DashboardEventBus.instance.notify(busCategory);
      }
    } catch (_) {
      try {
        await Future.delayed(const Duration(seconds: 5));
        final userId = _getUserIdInteractor?.execute() ?? '';
        if (userId.isNotEmpty) {
          await _synchronizeEventsInteractor?.execute(userId, fullSync: false);
        }
      } catch (_) {}
    }
  }

  static PrefsKeys? _categoryToPrefsKey(String? category) {
    switch (category) {
      case 'food': return PrefsKeys.foodEvents;
      case 'sport': return PrefsKeys.sportEvents;
      case 'supplement': return PrefsKeys.supplementEvents;
      default: return null;
    }
  }

  /// Trigger a full sync of all event categories (e.g. on app lifecycle resume).
  Future<void> triggerSync() async {
    try {
      final userId = _getUserIdInteractor?.execute() ?? '';
      if (userId.isEmpty) return;
      await _synchronizeEventsInteractor?.execute(userId, fullSync: false);
    } catch (_) {}
  }

  static DataChangedCategory? _categoryToBusCategory(String? category) {
    switch (category) {
      case 'food': return DataChangedCategory.food;
      case 'sport': return DataChangedCategory.sport;
      case 'supplement': return DataChangedCategory.supplement;
      default: return null;
    }
  }

  void Function(String)? _onTokenRefreshCallback;
  void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefreshCallback = callback;
  }

  void dispose() {
    _syncSubscription?.cancel();
    _messageController.close();
  }
}
