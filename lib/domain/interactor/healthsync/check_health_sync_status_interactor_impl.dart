import 'package:nutrenaissance_flutter/domain/interactor/healthsync/check_health_sync_status_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';

class CheckHealthSyncStatusInteractorImpl implements CheckHealthSyncStatusInteractor {
  final HealthSyncRepository healthSyncRepository;

  CheckHealthSyncStatusInteractorImpl({required this.healthSyncRepository});

  @override
  Future<bool> execute() async {
    final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
    if (!isAvailable) return false;

    final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
    if (!isEnabled) return false;

    final hasPermissions = await healthSyncRepository.hasPermissions();
    return hasPermissions;
  }
}
