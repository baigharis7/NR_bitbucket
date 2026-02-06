import 'package:nutrenaissance_flutter/domain/interactor/healthsync/toggle_health_sync_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/health_sync_background_service.dart';

class ToggleHealthSyncInteractorImpl implements ToggleHealthSyncInteractor {
  final HealthSyncRepository healthSyncRepository;

  ToggleHealthSyncInteractorImpl({required this.healthSyncRepository});

  @override
  Future<bool> execute(bool enable) async {
    try {
      if (enable) {
        // Check if sync is available
        final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
        if (!isAvailable) return false;

        // Check if we have permissions
        final hasPermissions = await healthSyncRepository.hasPermissions();
        if (!hasPermissions) {
          // Try to request permissions
          final granted = await healthSyncRepository.requestPermissions();
          if (!granted) return false;
        }

        // Enable sync
        await healthSyncRepository.setHealthSyncEnabled(true);

        // Register background sync task
        await HealthSyncBackgroundService.registerPeriodicSync();
      } else {
        // Disable sync
        await healthSyncRepository.setHealthSyncEnabled(false);

        // Cancel background sync task
        await HealthSyncBackgroundService.cancelPeriodicSync();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
