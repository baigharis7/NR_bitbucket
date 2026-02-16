import 'package:nutrenaissance_flutter/data/api/waterevents/water_events_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/water_events_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class WaterEventRepositoryImpl extends WaterEventsRepository {
  final WaterEventsApi waterEventsApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  WaterEventRepositoryImpl({required this.waterEventsApi, required this.localStorageRepository, required this.syncQueue});

  @override
  Future<bool> uploadWaterEvent(WaterEventMaster waterEventMaster) async {
    // Fire background API call (don't block UI)
    waterEventsApi.uploadWaterEvent(waterEventMaster).catchError((error) {
      syncQueue.enqueue('/water-event', waterEventMaster);
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<void> saveWaterEvent(WaterEventMaster waterEventMaster) async => await localStorageRepository.saveWaterEvent(waterEventMaster);

  @override
  Future<List<WaterEventMaster>> getWaterEventsToday({DateTime? dateTime}) async {
    final waterEventsEntities = await localStorageRepository.getWaterEventsToday(dateTime: dateTime);
    return waterEventsEntities.map((entity) => mapToWaterEventMaster(entity)).toList();
  }

  @override
  Future<List<WaterEventMaster>> getAllWaterEvents() async {
    final List allEvents = await localStorageRepository.getAllWaterEvents();
    return allEvents.map((waterEvent) => mapToWaterEventMaster(waterEvent as WaterEventEntity)).toList();
  }

}
