import 'package:workmanager_platform_interface/workmanager_platform_interface.dart';

/// Records every WorkManager platform call instead of executing it.
///
/// Option A guard: production code must never SCHEDULE background work.
/// Recording (rather than relying on the placeholder's UnimplementedError
/// throw) is deliberate — the old registration paths were fire-and-forget
/// with swallowed errors, so a throw-based guard would miss a reintroduced
/// call. Install via `WorkmanagerPlatform.instance = fake` and assert
/// [registrationCalls] stays empty.
class RecordingWorkmanagerPlatform extends WorkmanagerPlatform {
  final List<String> calls = [];

  /// Calls that would schedule background work.
  Iterable<String> get registrationCalls =>
      calls.where((call) => call.startsWith('register'));

  @override
  Future<void> initialize(
    Function callbackDispatcher, {
    // ignore: deprecated_consistency
    bool isInDebugMode = false,
  }) async {
    calls.add('initialize');
  }

  @override
  Future<void> registerOneOffTask(
    String uniqueName,
    String taskName, {
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    OutOfQuotaPolicy? outOfQuotaPolicy,
  }) async {
    calls.add('registerOneOffTask:$uniqueName');
  }

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
  }) async {
    calls.add('registerPeriodicTask:$uniqueName');
  }

  @override
  Future<void> registerProcessingTask(
    String uniqueName,
    String taskName, {
    Duration? initialDelay,
    Map<String, dynamic>? inputData,
    Constraints? constraints,
  }) async {
    calls.add('registerProcessingTask:$uniqueName');
  }

  @override
  Future<void> cancelByUniqueName(String uniqueName) async {
    calls.add('cancelByUniqueName:$uniqueName');
  }

  @override
  Future<void> cancelByTag(String tag) async {
    calls.add('cancelByTag:$tag');
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
  }

  @override
  Future<bool> isScheduledByUniqueName(String uniqueName) async {
    calls.add('isScheduledByUniqueName:$uniqueName');
    return false;
  }

  @override
  Future<String> printScheduledTasks() async {
    calls.add('printScheduledTasks');
    return '';
  }
}
