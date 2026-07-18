import 'package:health/health.dart';

/// Test-only description of a health data source (device/app). Used to stamp
/// [HealthDataPoint] source fields (`sourceName`/`sourcePlatform`/
/// `sourceDeviceId`/`sourceId`) coherently.
class HealthSource {
  final String name;
  final String id;
  final String deviceId;
  final HealthPlatformType platform;

  const HealthSource({
    required this.name,
    required this.id,
    required this.deviceId,
    required this.platform,
  });
}

// Apple Health presets → HealthPlatformType.appleHealth.
const HealthSource appleWatch = HealthSource(
  name: 'Apple Watch',
  id: 'apple-watch',
  deviceId: 'apple-watch-device',
  platform: HealthPlatformType.appleHealth,
);
const HealthSource iphone = HealthSource(
  name: 'iPhone',
  id: 'iphone',
  deviceId: 'iphone-device',
  platform: HealthPlatformType.appleHealth,
);

// Health Connect (Android) presets → HealthPlatformType.googleHealthConnect.
const HealthSource healthConnect = HealthSource(
  name: 'Health Connect',
  id: 'health-connect',
  deviceId: 'health-connect-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource samsungHealth = HealthSource(
  name: 'Samsung Health',
  id: 'samsung-health',
  deviceId: 'samsung-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource googleFit = HealthSource(
  name: 'Google Fit',
  id: 'google-fit',
  deviceId: 'google-fit-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource phone = HealthSource(
  name: 'Phone',
  id: 'phone',
  deviceId: 'phone-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource unknownSource = HealthSource(
  name: 'Unknown',
  id: 'unknown',
  deviceId: 'unknown-device',
  platform: HealthPlatformType.googleHealthConnect,
);

// Android writer-package sources (Health Connect reality: sourceName is the
// WRITER'S package name and sourceId is always '').
const HealthSource samsungHealthPackage = HealthSource(
  name: 'com.sec.android.app.shealth',
  id: '',
  deviceId: 'samsung-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource googleFitPackage = HealthSource(
  name: 'com.google.android.apps.fitness',
  id: '',
  deviceId: 'pixel-device',
  platform: HealthPlatformType.googleHealthConnect,
);
const HealthSource garminPackage = HealthSource(
  name: 'com.garmin.android.apps.connectmobile',
  id: '',
  deviceId: 'garmin-device',
  platform: HealthPlatformType.googleHealthConnect,
);
