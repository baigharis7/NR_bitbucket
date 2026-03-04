import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/health_sync_background_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

class ToggleHealthSyncInteractorImpl implements ToggleHealthSyncInteractor {
  final HealthSyncRepository healthSyncRepository;

  ToggleHealthSyncInteractorImpl({required this.healthSyncRepository});

  @override
  Future<bool> execute(bool enable) async {
    try {
      if (enable) {
        final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
        CrashlyticsService.instance.log('ToggleHealthSync: isAvailable=$isAvailable');
        if (!isAvailable) return false;

        final hasPermissions = await healthSyncRepository.hasPermissions();
        CrashlyticsService.instance.log('ToggleHealthSync: hasPermissions=$hasPermissions');
        if (!hasPermissions) {
          CrashlyticsService.instance.log('ToggleHealthSync: requesting permissions...');
          final granted = await healthSyncRepository.requestPermissions();
          CrashlyticsService.instance.log('ToggleHealthSync: permissions granted=$granted');
          if (!granted) return false;
        }

        await healthSyncRepository.setHealthSyncEnabled(true);
        await HealthSyncBackgroundService.registerPeriodicSync();
      } else {
        await healthSyncRepository.setHealthSyncEnabled(false);
        await HealthSyncBackgroundService.cancelPeriodicSync();
      }

      return true;
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {'method': 'ToggleHealthSync.execute', 'enable': '$enable'});
      return false;
    }
  }
}
