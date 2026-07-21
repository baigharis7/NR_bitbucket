import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

/// The host platform relevant to health sync.
enum HealthHostPlatform { android, ios, unsupported }

/// Callback shape for launching a URL, normalized so [LaunchMode] is always
/// explicit and the seam is trivially fakeable.
typedef LaunchUrlCallback = Future<bool> Function(Uri uri, {LaunchMode mode});

/// Test seam over platform- and device-level health integration that is not a
/// raw health-data read: platform resolution, availability, platform-specific
/// data types, imported source type, and Health Connect launch/install.
abstract class HealthPlatformService {
  /// The resolved host platform.
  HealthHostPlatform get hostPlatform;

  /// Platform-specific health data types to read and request permission for.
  List<HealthDataType> get readTypes;

  /// Platform-specific distance data type used for workout enrichment.
  HealthDataType get distanceType;

  /// Source type recorded on imported activities.
  String get importedSourceType;

  /// Whether [WorkoutHealthValue.totalEnergyBurned]/[totalDistance] are true
  /// per-session totals. iOS: yes — genuine HKWorkout totals. Android: no —
  /// the health plugin computes them by window-summing TotalCaloriesBurned /
  /// Distance records over the session window, so overlapping workouts
  /// cross-contaminate; they are only safe when the workout overlaps no
  /// other fetched workout.
  bool get workoutTotalsAreSessionScoped;

  /// Whether health sync is available on this device. May throw; callers
  /// preserve the current catch-to-false behavior.
  Future<bool> isHealthSyncAvailable();

  /// Open the Play Store to install Health Connect (Android only; else no-op).
  Future<void> installHealthConnect();

  /// Open the Health Connect app, falling back to the Play Store
  /// (Android only; else no-op).
  Future<void> openHealthConnect();
}

/// Production [HealthPlatformService].
///
/// Platform resolution, the native method channel, and URL launching are
/// injectable so the service is deterministic in unit tests; production
/// defaults require no configuration from callers.
class HealthPlatformServiceImpl implements HealthPlatformService {
  HealthPlatformServiceImpl({
    HealthHostPlatform? hostPlatform,
    Future<bool?> Function(String method)? invokeBool,
    Future<bool> Function(Uri uri)? canLaunch,
    LaunchUrlCallback? launch,
  }) : _hostPlatform = hostPlatform ?? _detectHostPlatform(),
       _invokeBool = invokeBool ?? _defaultInvokeBool,
       _canLaunch = canLaunch ?? canLaunchUrl,
       _launch = launch ?? _defaultLaunch;

  final HealthHostPlatform _hostPlatform;
  final Future<bool?> Function(String method) _invokeBool;
  final Future<bool> Function(Uri uri) _canLaunch;
  final LaunchUrlCallback _launch;

  static const _channel = MethodChannel('nutrenaissance/platform');
  static const _hcPackage = 'com.google.android.apps.healthdata';

  static HealthHostPlatform _detectHostPlatform() {
    if (Platform.isAndroid) return HealthHostPlatform.android;
    if (Platform.isIOS) return HealthHostPlatform.ios;
    return HealthHostPlatform.unsupported;
  }

  static Future<bool?> _defaultInvokeBool(String method) =>
      _channel.invokeMethod<bool>(method);

  static Future<bool> _defaultLaunch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) => launchUrl(uri, mode: mode);

  @override
  HealthHostPlatform get hostPlatform => _hostPlatform;

  @override
  List<HealthDataType> get readTypes => [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    if (_hostPlatform == HealthHostPlatform.ios)
      HealthDataType.DISTANCE_WALKING_RUNNING,
    if (_hostPlatform == HealthHostPlatform.android)
      HealthDataType.DISTANCE_DELTA,
  ];

  @override
  HealthDataType get distanceType => _hostPlatform == HealthHostPlatform.ios
      ? HealthDataType.DISTANCE_WALKING_RUNNING
      : HealthDataType.DISTANCE_DELTA;

  @override
  String get importedSourceType => _hostPlatform == HealthHostPlatform.ios
      ? 'apple_health'
      : 'health_connect';

  @override
  bool get workoutTotalsAreSessionScoped =>
      _hostPlatform == HealthHostPlatform.ios;

  @override
  Future<bool> isHealthSyncAvailable() async {
    switch (_hostPlatform) {
      case HealthHostPlatform.unsupported:
        return false;
      case HealthHostPlatform.android:
        // Native HealthConnectClient.getSdkStatus() is the reliable signal;
        // the health plugin's hasPermissions probe falls through to Google Fit
        // silently when HC is not installed.
        final result = await _invokeBool('isHealthConnectAvailable');
        debugPrint('[HealthSync] isHealthConnectAvailable=$result');
        CrashlyticsService.instance.log(
          'HealthSync: isHealthConnectAvailable=$result',
        );
        return result ?? false;
      case HealthHostPlatform.ios:
        // HealthKit is always available on supported iOS devices.
        return true;
    }
  }

  @override
  Future<void> installHealthConnect() async {
    if (_hostPlatform != HealthHostPlatform.android) return;
    await _launchStoreListing();
  }

  @override
  Future<void> openHealthConnect() async {
    if (_hostPlatform != HealthHostPlatform.android) return;
    final opened = await _invokeBool('openHealthConnect');
    if (opened != true) {
      await _launchStoreListing();
    }
  }

  /// Open the Health Connect Play Store listing, preferring the `market://`
  /// deep link and falling back to the web URL (external) when it can't launch.
  Future<void> _launchStoreListing() async {
    final marketUri = Uri.parse('market://details?id=$_hcPackage');
    if (await _canLaunch(marketUri)) {
      await _launch(marketUri);
    } else {
      await _launch(
        Uri.parse('https://play.google.com/store/apps/details?id=$_hcPackage'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
