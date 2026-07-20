import 'package:flutter/foundation.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

class ToggleHealthSyncInteractorImpl implements ToggleHealthSyncInteractor {
  final HealthSyncRepository healthSyncRepository;

  ToggleHealthSyncInteractorImpl({required this.healthSyncRepository});

  @override
  Future<bool> execute(bool enable) async {
    try {
      if (enable) {
        final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
        debugPrint('[HealthSync] ToggleHealthSync: isAvailable=$isAvailable');
        CrashlyticsService.instance.log('ToggleHealthSync: isAvailable=$isAvailable');
        if (!isAvailable) return false;

        final hasPermissions = await healthSyncRepository.hasPermissions();
        debugPrint('[HealthSync] ToggleHealthSync: hasPermissions=$hasPermissions');
        CrashlyticsService.instance.log('ToggleHealthSync: hasPermissions=$hasPermissions');
        if (!hasPermissions) {
          debugPrint('[HealthSync] ToggleHealthSync: requesting permissions...');
          CrashlyticsService.instance.log('ToggleHealthSync: requesting permissions...');
          final granted = await healthSyncRepository.requestPermissions();
          debugPrint('[HealthSync] ToggleHealthSync: permissions granted=$granted');
          CrashlyticsService.instance.log('ToggleHealthSync: permissions granted=$granted');
          if (!granted) return false;
        }

        await healthSyncRepository.setHealthSyncEnabled(true);
      } else {
        await healthSyncRepository.setHealthSyncEnabled(false);
      }

      return true;
    } catch (e, stack) {
      debugPrint('[HealthSync] ToggleHealthSync ERROR: $e\n$stack');
      CrashlyticsService.record(e, stack, context: {'method': 'ToggleHealthSync.execute', 'enable': '$enable'});
      return false;
    }
  }
}
