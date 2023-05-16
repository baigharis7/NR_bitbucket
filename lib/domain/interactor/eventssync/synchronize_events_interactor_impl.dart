import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';

class SynchronizeEventsInteractorImpl extends SynchronizeEventsInteractor {
  final EventsSynchronizationRequestRepository eventsSynchronizationRequestRepository;

  SynchronizeEventsInteractorImpl({required this.eventsSynchronizationRequestRepository});

  @override
  Future<void> execute(String userId) async => await eventsSynchronizationRequestRepository.synchronizeEvents(userId);
}