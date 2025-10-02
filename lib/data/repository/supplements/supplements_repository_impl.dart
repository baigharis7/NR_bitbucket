import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/supplement_mappers.dart';

class SupplementsRepositoryImpl extends SupplementsRepository {
  final SupplementApi supplementApi;
  final LocalStorageRepository localStorageRepository;


  SupplementsRepositoryImpl({required this.supplementApi, required this.localStorageRepository});

  @override
  Future<UploadSupplementEvent?> getTodayCreatineEvent({DateTime? dateTime}) async {
    try {
      final result = await localStorageRepository.getCreatineTodayEvent(dateTime: dateTime);
      return mapToSupplementEvent(result);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveCreatineEvent(UploadSupplementEvent uploadSupplementCreatineEvent, bool isEdit) async {
    try {
      await localStorageRepository.saveCreatineEvent(mapToSupplementEventEntity(uploadSupplementCreatineEvent), isEdit: isEdit);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> uploadCreatineEvent(UploadSupplementEvent uploadSupplementEvent) async {
    try {
      await supplementApi.uploadCreatineEvent(uploadSupplementEvent);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UploadSupplementEvent?> getTodayCollagenEvent({DateTime? dateTime}) async {
    try {
      final result = await localStorageRepository.getCollagenTodayEvent(dateTime: dateTime);
      return mapToSupplementEvent(result);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> uploadCollagenEvent(UploadSupplementEvent uploadSupplementCollagenEvent,) async {
    try {
      await supplementApi.uploadCollagenEvent(uploadSupplementCollagenEvent);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveCollagenEvent(UploadSupplementEvent uploadSupplementCollagenEvent, bool isEdit) async {
    try {
      await localStorageRepository.saveCollagenEvent(mapToSupplementEventEntity(uploadSupplementCollagenEvent), isEdit: isEdit);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadSupplementEvent>> getAllCreatineEvents() async {
      final List allEvents = await localStorageRepository.getAllCreatineEvents();
      return allEvents.map((creatineEvent) => mapToSupplementEvent(creatineEvent as UploadSupplementEventEntity)).toList();
  }

  @override
  Future<List<UploadSupplementEvent>> getAllCollagenEvents() async {
    final List allEvents = await localStorageRepository.getAllCreatineEvents();
    return allEvents.map((creatineEvent) => mapToSupplementEvent(creatineEvent as UploadSupplementEventEntity)).toList();
  }

  //New
  @override
  Future<void> uploadSupplementEvent(UploadSupplementsEv uploadSupplementsEv) async {
    try {
      await supplementApi.uploadSupplementEvent(uploadSupplementsEv);
    } catch(_) {
      rethrow;
    }
  }

}