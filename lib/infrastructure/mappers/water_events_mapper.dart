import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

WaterEventEntity mapToWaterEventEntity(WaterEventMaster waterEventMaster) => WaterEventEntity(waterEventMaster.userId, waterEventMaster.eventDate, waterEventMaster.eventId, waterEventMaster.qty!);

WaterEventMaster mapToWaterEventMaster(WaterEventEntity waterEventEntity) => WaterEventMaster(waterEventEntity.userId, waterEventEntity.eventDate, waterEventEntity.eventId, waterEventEntity.qty);