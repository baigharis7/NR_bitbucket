import 'package:nutrenaissance_flutter/domain/interactor/healthsync/request_health_permissions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';

class RequestHealthPermissionsInteractorImpl implements RequestHealthPermissionsInteractor {
  final HealthSyncRepository healthSyncRepository;

  RequestHealthPermissionsInteractorImpl({required this.healthSyncRepository});

  @override
  Future<bool> execute() async {
    // First check if health sync is available on this device
    final isAvailable = await healthSyncRepository.isHealthSyncAvailable();
    if (!isAvailable) return false;

    // Request permissions
    return await healthSyncRepository.requestPermissions();
  }
}
