import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/eventssync/events_synchronization_repository.dart';

class UpdateEventsInteractorImpl extends UpdateEventsInteractor {
  final EventsSynchronizationRequestRepository eventsSynchronizationRequestRepository;

  UpdateEventsInteractorImpl({required this.eventsSynchronizationRequestRepository});

  @override
  Future<bool> execute({required String userId, required String categoryType, required bool fullSync}) => eventsSynchronizationRequestRepository.fetchEvents(userId, categoryType, fullSync: fullSync);



}