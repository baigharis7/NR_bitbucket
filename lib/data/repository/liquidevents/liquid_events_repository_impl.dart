import 'package:nutrenaissance_flutter/data/api/liquidevents/liquid_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/liquidevents/liquid_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/liquid_event_mappers.dart';

class LiquidEventsRepositoryImpl extends LiquidEventsRepository{
  final LocalStorageRepository localStorageRepository;
  final LiquidEventsApi liquidEventsApi;

  LiquidEventsRepositoryImpl({required this.liquidEventsApi, required this.localStorageRepository});

  @override
  Future<UploadLiquidEvent> uploadLiquidEvent(LiquidEventSimple liquidEventSimple) async {
    final liquidEvent = await liquidEventsApi.uploadLiquidEvent(liquidEventSimple);
    return UploadLiquidEvent.fromJson(liquidEvent);
  }

  @override
  Future<void> saveLiquidEvent(UploadLiquidEvent uploadLiquidEvent, bool isEdit) async {
    final liquidEventEntity = mapToLiquidEventEntity(uploadLiquidEvent);
    localStorageRepository.saveLiquidEvent(liquidEventEntity, isEdit);
  }

  @override
  Future<List<LiquidEventComplete>> getTodayLiquidEvents() async {
    final List allEvents = await localStorageRepository.getTodayLiquidEvents();
    return allEvents.map((liquidEvent) => mapToLiquidEventComplete(liquidEvent)).toList();
  }

  @override
  Future<List<LiquidEventComplete>> getWeeklyLiquidEvents() async {
    final List allEvents = await localStorageRepository.getWeeklyLiquidEvents();
    return allEvents.map((liquidEvent) => mapToLiquidEventComplete(liquidEvent)).toList();
  }

  @override
  Future<List<LiquidEventComplete>> getAllLiquidEvents() async {
    final List allEvents = await localStorageRepository.getAllLiquidEvents();
    return allEvents.map((liquidEvent) => mapToLiquidEventComplete(liquidEvent as LiquidEventEntity)).toList();
  }

  @override
  Future<void> deleteLiquidEvent(String userId, int eventDate) => liquidEventsApi.deleteLiquidEvent(userId, eventDate);

  @override
  Future<void> removeLiquidEvent(LiquidEventComplete liquidEventComplete) async {
    try {
      await localStorageRepository.removeLiquidEvent(mapToLiquidEventEntityFromComplete(liquidEventComplete));
    } catch (error) {
      rethrow;
    }
  }

}