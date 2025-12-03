import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

class UpdateEventsInteractorImpl extends UpdateEventsInteractor {
  final EventsSynchronizationRequestRepository eventsSynchronizationRequestRepository;

  UpdateEventsInteractorImpl({required this.eventsSynchronizationRequestRepository});

  @override
  Future<bool> execute({required String userId, required PrefsKeys categoryType, required bool fullSync}) => eventsSynchronizationRequestRepository.fetchEvents(userId, categoryType, fullSync: fullSync);



}