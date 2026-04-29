import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/step_events_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

import '../../../domain/repository/localstorage/local_storage.dart';
import '../../api/steps/models/step_event_response.dart';

class StepsRepositoryImpl extends StepsRepository {
  final StepsApi stepsApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  StepsRepositoryImpl({required this.stepsApi, required this.localStorageRepository, required this.syncQueue});

  @override
  Future<bool> uploadSteps(StepEventResponse stepEventResponse) async {
    final userId = await localStorageRepository.getProfile().then((value) => value?.userId.orEmpty());
    final uploadModel = mapToUploadStepEventResponse(userId.orEmpty(), stepEventResponse);
    // Fire-and-forget: don't block UI on network call
    stepsApi.uploadSteps(uploadModel).catchError((error) {
      syncQueue.enqueue('/steps-count', uploadModel);
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<void> saveSteps(StepEventResponse stepEventResponse) => localStorageRepository.saveSteps(mapToStepEntity(stepEventResponse));

  @override
  Future<List<StepEventResponse>> getSteps() async {
    final stepEvents = await localStorageRepository.getTodaySteps();
    return stepEvents.map((e) => mapToStepEventResponse(e as StepsEntity)).toList();
  }

  @override
  Future<StepEventResponse> todayStep() async {
    final stepEntity = await localStorageRepository.getTodayStep();
    return mapToStepEventResponse(stepEntity);
  }

}