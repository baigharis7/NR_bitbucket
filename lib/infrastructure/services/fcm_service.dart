import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  FcmService._privateConstructor();
  static final FcmService instance = FcmService._privateConstructor();

  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onDataMessage => _messageController.stream;
  String? _token;
  String? get token => _token;

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

  void Function(String)? _onTokenRefreshCallback;
  void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefreshCallback = callback;
  }

  void dispose() {
    _messageController.close();
  }
}
