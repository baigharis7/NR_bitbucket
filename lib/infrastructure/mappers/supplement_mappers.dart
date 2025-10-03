import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/supplement_events_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

UploadSupplementEventEntity mapToSupplementEventEntity(
        UploadSupplementEvent uploadSupplementEvent) =>
    UploadSupplementEventEntity(
      userId: uploadSupplementEvent.userId,
      eventId: uploadSupplementEvent.eventId,
      value: uploadSupplementEvent.value,
    );

UploadSupplementEvent mapToSupplementEvent(
        UploadSupplementEventEntity? uploadSupplementEventEntity) =>
    UploadSupplementEvent(
      userId: uploadSupplementEventEntity?.userId,
      eventId: uploadSupplementEventEntity?.eventId,
      value: uploadSupplementEventEntity?.value,
    );

UploadSupplementsEv mapToUploadSupplementsEv(SupplementSimple supplementSimple) =>
    UploadSupplementsEv(
      userId: supplementSimple.userId!,
      eventId: supplementSimple.eventId!,
      eventDate: supplementSimple.eventDate!,
      info: supplementSimple.info.orEmpty().map((e) => UploadSupplementInfo(id: e.id, amount: e.amount, unit: e.unit)).toList(),
    );

SupplementEventsEntity mapToSupplementEventsEntity(UploadSupplementsEv uploadSupplementsEv) =>
    SupplementEventsEntity(
      userId: uploadSupplementsEv.userId,
      eventId: uploadSupplementsEv.eventId,
      eventDate: uploadSupplementsEv.eventDate,
      info: uploadSupplementsEv.info.map((e) => SupplementEventsInfoEntity(id: e.id, amount: e.amount.toString(), unit: e.unit)).toList(),
    );

SupplementSimple mapToSupplementSimple(SupplementEventsEntity supplementEventsEntity) =>
    SupplementSimple(
      userId: supplementEventsEntity.userId,
      eventId: supplementEventsEntity.eventId,
      eventDate: supplementEventsEntity.eventDate,
      info: supplementEventsEntity.info.map((e) => NutriInfo(id: e.id, unit: e.unit, amount: int.parse(e.amount))).toList(),
    );

SupplementEventsEntity mapToSupplementEventEntityFromSupplementSimple(SupplementSimple supplementSimple) =>
    SupplementEventsEntity(
      userId: supplementSimple.userId!,
      eventId: supplementSimple.eventId!,
      eventDate: supplementSimple.eventDate!,
      info: supplementSimple.info.orEmpty().map((e) => SupplementEventsInfoEntity(id: e.id, amount: e.amount.toString(), unit: e.unit)).toList(),
    );