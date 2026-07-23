import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/step_display_resolver.dart';

void main() {
  group('resolveDisplayedStepCount', () {
    test('sync ON: sensor is authoritative, estimate is not added', () {
      final state = HealthSyncState(
        isSyncEnabled: true,
        todayStepCount: 3000,
        estimatedStepCount: 2400,
      );

      expect(resolveDisplayedStepCount(state), 3000);
    });

    test('sync OFF: displayed steps are the estimate', () {
      final state = HealthSyncState(
        isSyncEnabled: false,
        estimatedStepCount: 2400,
      );

      expect(resolveDisplayedStepCount(state), 2400);
    });

    test('sync ON with no sensor value: never falls back to the estimate', () {
      final state = HealthSyncState(
        isSyncEnabled: true,
        todayStepCount: null,
        estimatedStepCount: 2400,
      );

      expect(resolveDisplayedStepCount(state), 0);
    });
  });
}
