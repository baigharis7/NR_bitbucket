import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class CrashlyticsService {
  CrashlyticsService._privateConstructor();
  static final CrashlyticsService instance = CrashlyticsService._privateConstructor();

  FirebaseCrashlytics? _crashlyticsInstance;
  FirebaseCrashlytics get _crashlytics {
    try {
      return _crashlyticsInstance ??= FirebaseCrashlytics.instance;
    } catch (_) {
      rethrow;
    }
  }

  /// Initialize Crashlytics
  Future<void> init() async {
    // Pass all uncaught Flutter errors to Crashlytics.
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      FlutterError.dumpErrorToConsole(errorDetails);
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all Zone errors to Crashlytics
    runZonedGuarded(() {
      // Your App Initialization Code (usually runApp(MyApp()))
    }, (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
    });
  }

  /// Enable or disable crashlytics (useful for dev mode)
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Set user identifier for better crash tracking
  Future<void> setUserId(String id) async {
    await _crashlytics.setUserIdentifier(id);
  }

  /// Set custom key/value (string, int, bool, double)
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Log informational messages to be visible in Crashlytics
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (_) {
      // Firebase not initialized (e.g. in tests)
    }
  }

  /// Manually record handled exceptions
  Future<void> recordError(dynamic error, StackTrace stack,
      {bool fatal = false}) async {
    await _crashlytics.recordError(error, stack, fatal: fatal);
  }

  /// Force a test crash
  Future<void> testCrash() async {
    _crashlytics.crash();
  }

  /// Record a handled exception as a non-fatal Crashlytics event.
  ///
  /// Awaits both the custom-key writes and the recordError call so the event
  /// is durably queued before this returns. Earlier fire-and-forget version
  /// lost events when the caller's frame popped immediately after recording
  /// (auth flow → snackbar → user retries → app backgrounds), which is why
  /// the dashboard was empty despite instrumentation being in place.
  static Future<void> record(dynamic error, StackTrace? stack,
      {Map<String, dynamic>? context,}) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      if (context != null) {
        for (final entry in context.entries) {
          await crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }
      await crashlytics.recordError(
        error,
        stack ?? StackTrace.current,
        fatal: false,
      );
    } catch (_) {
      // Firebase not initialized (e.g. in tests) — swallow.
    }
  }
}