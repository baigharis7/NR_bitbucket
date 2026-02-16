import 'package:nutrenaissance_flutter/data/api/fecesurine/fece_urine_api.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/feces_urine_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class FecesUrineRepositoryImpl extends FecesUrineRepository {
  final FecesUrineApi fecesUrineApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  FecesUrineRepositoryImpl({required this.fecesUrineApi, required this.localStorageRepository, required this.syncQueue,});

  @override
  Future<void> uploadFeces(UploadFeces uploadFeces) async {
    fecesUrineApi.uploadFeces(uploadFeces).catchError((error) {
      syncQueue.enqueue('/feces', uploadFeces);
      return <String, dynamic>{};
    });
  }

  @override
  Future<List<UploadFeces>> getFecesEvents() async {
    try {
      final result = await localStorageRepository.getFecesEvents();
      return result.map((e) => mapToUploadFeces(e as UploadFecesEventEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadFeces>> getFecesEventsByDate({DateTime? dateTime, DateTime? endDate, int? days}) async {
    try {
      final result = await localStorageRepository.getFecesEventsByDate(dateTime: dateTime, endDate: endDate, days: days);
      return result.map((e) => mapToUploadFeces(e as UploadFecesEventEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadFeces>> getUrineEventsByDate({DateTime? dateTime, DateTime? endDate, int? days}) async {
    try {
      final result = await localStorageRepository.getUrineEventsByDate(dateTime: dateTime, endDate: endDate, days: days,);
      return result.map((e) => mapToUploadFeces(e as UploadFecesEventEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveFecesEvent(UploadFeces uploadFeces) async {
    try {
      await localStorageRepository.saveFecesEvent(mapToUploadFecesEventEntity(uploadFeces));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadFeces>> getUrineEvents() async {
    try {
      final result = await localStorageRepository.getUrineEvents();
      return result.map((e) => mapToUploadFeces(e as UploadFecesEventEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveUrineEvent(UploadFeces uploadUrine) async {
    try {
      await localStorageRepository.saveUrineEvent(mapToUploadFecesEventEntity(uploadUrine));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> uploadUrine(UploadFeces uploadUrine) async {
    fecesUrineApi.uploadUrineEvent(uploadUrine).catchError((error) {
      syncQueue.enqueue('/urine', uploadUrine);
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> deleteFecesEvent(String userId, int eventId) async {
    fecesUrineApi.deleteFecesEvent(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/feces', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeFecesEvent(UploadFeces uploadFeces) async {
    try {
      await localStorageRepository.removeFecesEvent(mapToUploadFecesEventEntity(uploadFeces));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUrineEvent(String userId, int eventId) async {
    fecesUrineApi.deleteUrineEvent(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/urine', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeUrineEvent(UploadFeces uploadUrine) async {
    try {
      await localStorageRepository.removeUrineEvent(mapToUploadFecesEventEntity(uploadUrine));
    } catch (error) {
      rethrow;
    }
  }

}