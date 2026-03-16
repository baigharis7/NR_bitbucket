import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/supplement_events_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/supplement_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

import '../../../domain/models/supplements/supplement_simple.dart';

class SupplementsRepositoryImpl extends SupplementsRepository {
  final SupplementApi supplementApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  SupplementsRepositoryImpl({required this.supplementApi, required this.localStorageRepository, required this.syncQueue});

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
    supplementApi.uploadCreatineEvent(uploadSupplementEvent).catchError((error) {
      syncQueue.enqueue('/creatine', uploadSupplementEvent);
      return <String, dynamic>{};
    });
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
    supplementApi.uploadCollagenEvent(uploadSupplementCollagenEvent).catchError((error) {
      syncQueue.enqueue('/collagen', uploadSupplementCollagenEvent);
      return <String, dynamic>{};
    });
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
    supplementApi.uploadSupplementEvent(uploadSupplementsEv).catchError((error) {
      syncQueue.enqueue('/supplements', uploadSupplementsEv);
      return <String, dynamic>{};
    });
  }

  @override
  Future<List<SupplementSimple>> getSupplementEventsDay({DateTime? dateTime}) async {
    try {
      final List events = await localStorageRepository.getSupplementEventsDay(dateTime: dateTime);
      return events.map((event) => mapToSupplementSimple(event as SupplementEventsEntity)).toList();
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<List<SupplementSimple>> getAllSupplementEvents() async {
    final List events = await localStorageRepository.getAllSupplementEvents();
    return events.map((event) => mapToSupplementSimple(event as SupplementEventsEntity)).toList();
  }

  @override
  Future<List<SupplementSimple>> getRecentSupplementEvents() async {
    final List events = await localStorageRepository.getRecentSupplementEvents();
    return events.map((event) => mapToSupplementSimple(event as SupplementEventsEntity)).toList();
  }

  @override
  Future<void> saveSupplementEvent(SupplementSimple supplementSimple, bool isEdit) async {
    try {
      await localStorageRepository.saveSupplementEvent(mapToSupplementEventEntityFromSupplementSimple(supplementSimple), isEdit: isEdit);
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplementEvent(SupplementSimple supplementEvent) async {
    supplementApi.deleteSupplementEvent(supplementEvent).catchError((error) {
      syncQueue.enqueueDelete('/supplements', {'userId': supplementEvent.userId, 'eventId': supplementEvent.eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeSupplementEvent(SupplementSimple supplementEvent) async {
    try {
      await localStorageRepository.removeSupplementEvent(mapToSupplementEventEntityFromSupplementSimple(supplementEvent));
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<void> uploadSupplementFavorite(SupplementFavorite supplementFavorite) async {
    supplementApi.uploadSupplementFavorite(supplementFavorite).catchError((error) {
      syncQueue.enqueue('/favorites/supplement', supplementFavorite);
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> saveSupplementFavorite(SupplementFavorite supplementFavorite, bool isEdit) async {
    try {
      await localStorageRepository.saveSupplementFavorite(mapToSupplementEventEntityFromFavorite(supplementFavorite), isEdit: isEdit);
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<List<SupplementSimple>> getSupplementFavorite() async {
    try {
      final List events = await localStorageRepository.getSupplementFavorites();
      return events.map((event) => mapToSupplementSimpleFavorite(event as SupplementEventsEntity)).toList();
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<void> uploadSupplementRoutine(UploadSupplementRoutine uploadSupplementRoutine) async {
    supplementApi.uploadSupplementRoutine(uploadSupplementRoutine).catchError((error) {
      syncQueue.enqueue('/supplement-routines', uploadSupplementRoutine);
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> saveSupplementRoutine(UploadSupplementRoutine supplementRoutine, bool isEdit) async {
    try {
      await localStorageRepository.saveSupplementRoutine(mapToSupplementEventEntityFromRoutine(supplementRoutine), isEdit: isEdit);
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<List<SupplementSimple>> getSupplementRoutines() async {
    try {
      final supplementRoutines = await localStorageRepository.getSupplementRoutines();
      return supplementRoutines.map((e) => mapToSupplementSimpleFromSupplementEntity(e as SupplementEventsEntity)).toList();
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplementRoutine(SupplementSimple supplement) async {
    supplementApi.deleteSupplementRoutine(supplement).catchError((error) {
      syncQueue.enqueueDelete('/supplement-routines', {'userId': supplement.userId, 'eventId': supplement.eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeSupplementRoutine(SupplementSimple supplement) async {
    try {
      await localStorageRepository.removeSupplementRoutine(mapToSupplementEventEntityFromSupplementSimple(supplement));
    } catch(_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplementFavorite(SupplementSimple supplement) async {
    supplementApi.deleteSupplementFavorite(supplement).catchError((error) {
      syncQueue.enqueueDelete('/favorites/supplement', {'userId': supplement.userId, 'eventId': supplement.eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeSupplementFavorite(SupplementSimple supplement) async {
    try {
      await localStorageRepository.removeSupplementFavorite(mapToSupplementEventEntityFromSupplement(supplement));
    } catch(_) {
      rethrow;
    }
  }


}