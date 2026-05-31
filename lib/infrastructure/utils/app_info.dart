import 'package:package_info_plus/package_info_plus.dart';

/// Lazily-loaded app version / build number so non-async call sites
/// (snackbar composers, error dialogs) can read it synchronously after the
/// one-time async load in app bootstrap.
class AppInfo {
  static String _version = '?';
  static String _buildNumber = '?';

  /// `1.1.0 (265)`. `?` until [load] resolves.
  static String get versionLabel => '$_version ($_buildNumber)';

  /// Call once from app_bootstrap before any UI that needs the label.
  static Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _buildNumber = info.buildNumber;
    } catch (_) {
      // Plugin not registered (tests) — keep the '?' defaults.
    }
  }
}
