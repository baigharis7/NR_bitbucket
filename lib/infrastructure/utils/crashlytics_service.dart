import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class CrashlyticsService {
  CrashlyticsService._privateConstructor();
  static final CrashlyticsService instance = CrashlyticsService._privateConstructor();

  /// Last message passed to [log]. Mirrored in-memory so the login error
  /// snackbar can surface the most recent breadcrumb in its diagnostic block —
  /// Crashlytics non-fatals only upload on the next app session, but the
  /// snackbar can read this value right now.
  static String? lastBreadcrumb;

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
    lastBreadcrumb = message;
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

  /// Record a handled exception as a Crashlytics event.
  ///
  /// Awaits both the custom-key writes and the recordError call so the event
  /// is durably queued before this returns. Earlier fire-and-forget version
  /// lost events when the caller's frame popped immediately after recording
  /// (auth flow → snackbar → user retries → app backgrounds), which is why
  /// the dashboard was empty despite instrumentation being in place.
  ///
  /// Pass `fatal: true` for failures we want surfaced same-session — Firebase
  /// uploads fatals via a separate background path on iOS instead of
  /// waiting for the next app launch like non-fatals do. Use sparingly:
  /// fatals pollute the crash-free-users stat. Reserved for failures in the
  /// post-signin chain where the user is otherwise stuck.
  static Future<void> record(dynamic error, StackTrace? stack,
      {Map<String, dynamic>? context, bool fatal = false,}) async {
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
        fatal: fatal,
      );
    } catch (_) {
      // Firebase not initialized (e.g. in tests) — swallow.
    }
  }
}