import 'package:health/health.dart';

/// Test seam over the `health` package's authorization, permission-check, and
/// read operations used by health sync.
///
/// Returns raw [HealthDataPoint] values so the repository mapper remains the
/// only interpreter of workout, numeric, source, and time fields. This is the
/// smallest behavior-preserving seam.
abstract class HealthPlatformClient {
  /// Request read authorization for [types] with matching [permissions].
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  });

  /// Check permissions for [types] with matching [permissions].
  /// May return `null` (plugin-defined "unknown"); callers preserve that.
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  });

  /// Read raw records for [types] between [startTime] and [endTime].
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
  });
}

/// Production [HealthPlatformClient] that delegates to the `health` package.
///
/// The [Health] instance is created lazily on first use to preserve the
/// repository's current non-blocking startup behavior. [healthFactory] is
/// injectable so delegation can be verified against a mocked [Health].
class HealthPlatformClientImpl implements HealthPlatformClient {
  HealthPlatformClientImpl({Health Function()? healthFactory})
      : _healthFactory = healthFactory ?? Health.new;

  final Health Function() _healthFactory;
  Health? _health;
  Health get _healthInstance => _health ??= _healthFactory();

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  }) {
    return _healthInstance.requestAuthorization(types, permissions: permissions);
  }

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  }) {
    return _healthInstance.hasPermissions(types, permissions: permissions);
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return _healthInstance.getHealthDataFromTypes(
      types: types,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
