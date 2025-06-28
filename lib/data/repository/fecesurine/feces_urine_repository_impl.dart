import 'package:nutrenaissance_flutter/data/api/fecesurine/fece_urine_api.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/feces_urine_mappers.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class FecesUrineRepositoryImpl extends FecesUrineRepository {
  final FecesUrineApi fecesUrineApi;
  final LocalStorageRepository localStorageRepository;

  FecesUrineRepositoryImpl({required this.fecesUrineApi, required this.localStorageRepository,});

  @override
  Future<void> uploadFeces(UploadFeces uploadFeces) async {
    try {
      await fecesUrineApi.uploadFeces(uploadFeces);
    } catch (error) {
      rethrow;
    }
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
  Future<List<UploadFeces>> getFecesEventsByDate({DateTime? dateTime, int? prevDays}) async {
    try {
      final result = await localStorageRepository.getFecesEventsByDate(dateTime: dateTime, prevDays: prevDays);
      return result.map((e) => mapToUploadFeces(e as UploadFecesEventEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadFeces>> getUrineEventsByDate({DateTime? dateTime, int? prevDays}) async {
    try {
      final result = await localStorageRepository.getUrineEventsByDate(dateTime: dateTime, prevDays: prevDays);
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
    try {
      await fecesUrineApi.uploadUrineEvent(uploadUrine);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> deleteFecesEvent(String userId, int eventId) async {
    try {
      await fecesUrineApi.deleteFecesEvent(userId, eventId);
    } catch (error) {
      rethrow;
    }
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
    try {
      await fecesUrineApi.deleteUrineEvent(userId, eventId);
    } catch (error) {
      rethrow;
    }
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