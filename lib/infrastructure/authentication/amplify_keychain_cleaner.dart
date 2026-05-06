import 'package:flutter/services.dart';

/// Wipes Amplify's persisted credential storage (iOS Keychain entries,
/// Android EncryptedSharedPreferences). Used to self-heal when Amplify
/// gets stuck on stale state from a previous install/session/version.
class AmplifyKeychainCleaner {
  static const _channel = MethodChannel('nutrenaissance/platform');

  static Future<void> wipe() async {
    try {
      await _channel
          .invokeMethod('wipeAmplifyState')
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Best-effort. If the wipe fails or times out we still want callers to
      // proceed with whatever recovery they have planned.
    }
  }
}
