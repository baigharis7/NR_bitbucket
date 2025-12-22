import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class CrashlyticsService {
  CrashlyticsService._privateConstructor();
  static final CrashlyticsService instance = CrashlyticsService._privateConstructor();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

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
    await _crashlytics.log(message);
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

  static void record(dynamic error, StackTrace? stack, {Map<String, dynamic>? context}) {
    if (context != null) {
      context.forEach((key, value) {
        FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      });
    }

    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  }
}