import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/health_sync_background_service.dart';

/// T6 (Option A): no closed-app background sync exists. The dispatcher's
/// task handler survives only so a stale pre-upgrade WorkManager task can
/// complete harmlessly — it must succeed for any task name and touch no
/// data. Running it here with no bindings, no Hive, and no plugins proves
/// the no-mutation property: any I/O attempt would throw.
void main() {
  test('legacy task handler succeeds without touching any data', () async {
    expect(
      await handleDecommissionedBackgroundTask(
        HealthSyncBackgroundService.healthSyncTaskName,
      ),
      isTrue,
    );
  });

  test('legacy task handler succeeds for unknown task names too', () async {
    expect(await handleDecommissionedBackgroundTask('someOtherTask'), isTrue);
  });
}
