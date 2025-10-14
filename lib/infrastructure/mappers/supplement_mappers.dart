import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
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
      name: supplementSimple.name.orEmpty(),
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
      name: supplementEventsEntity.name,
    );

SupplementEventsEntity mapToSupplementEventEntityFromSupplementSimple(SupplementSimple supplementSimple) =>
    SupplementEventsEntity(
      userId: supplementSimple.userId!,
      eventId: supplementSimple.eventId!,
      eventDate: supplementSimple.eventDate!,
      info: supplementSimple.info.orEmpty().map((e) => SupplementEventsInfoEntity(id: e.id, amount: e.amount.toString(), unit: e.unit)).toList(),
      name: supplementSimple.name,
    );

SupplementFavorite mapToSupplementFavoriteFromSupplement(SupplementSimple supplement) =>
    SupplementFavorite(
        userId: supplement.userId!,
        eventId: supplement.eventId!,
        eventDate: supplement.eventDate!,
        data: supplement.info.orEmpty().map((e) => SupplementFavoriteNutrient(id: e.id, amount: e.amount, unit: e.unit)).toList(),
        name: supplement.name,
    );

SupplementEventsEntity mapToSupplementEventEntityFromFavorite(SupplementFavorite supplementFavorite) =>
    SupplementEventsEntity(
      userId: supplementFavorite.userId,
      eventId: supplementFavorite.eventId,
      eventDate: supplementFavorite.eventDate,
      info: supplementFavorite.data.map((e) => SupplementEventsInfoEntity(id: e.id, amount: e.amount.toString(), unit: e.unit)).toList(),
      name: supplementFavorite.name,
    );

UploadSupplementRoutine mapToSupplementRoutineFromSupplement(SupplementSimple supplement) =>
    UploadSupplementRoutine(
        userId: supplement.userId!,
        eventId: supplement.eventId!,
        eventDate: supplement.eventDate!,
        info: supplement.info.orEmpty().map((e) => UploadSupplementRoutineInfo(id: e.id, amount: e.amount, unit: e.unit)).toList(),
        name: supplement.name,
        time: supplement.scheduleTime!,
        daysOfWeek: supplement.daysOfWeek.orEmpty(),
        timeZone: supplement.timeZone.orEmpty(),
    );

SupplementEventsEntity mapToSupplementEventEntityFromRoutine(UploadSupplementRoutine supplementRoutine) =>
    SupplementEventsEntity(
      userId: supplementRoutine.userId,
      eventId: supplementRoutine.eventId,
      eventDate: supplementRoutine.eventDate,
      info: supplementRoutine.info.map((e) => SupplementEventsInfoEntity(id: e.id, amount: e.amount.toString(), unit: e.unit)).toList(),
      name: supplementRoutine.name,
      scheduleTime: supplementRoutine.time,
      daysOfWeek: supplementRoutine.daysOfWeek,
      timeZone: supplementRoutine.timeZone.orEmpty(),
    );

SupplementSimple mapToSupplementSimpleFromSupplementEntity(SupplementEventsEntity supplementEntity) =>
    SupplementSimple(
      userId: supplementEntity.userId,
      eventId: supplementEntity.eventId,
      eventDate: supplementEntity.eventDate,
      info: supplementEntity.info.map((e) => NutriInfo(id: e.id, amount: int.parse(e.amount), unit: e.unit)).toList(),
      name: supplementEntity.name,
      isRoutine: true,
      scheduleTime: supplementEntity.scheduleTime,
      daysOfWeek: supplementEntity.daysOfWeek,
      timeZone: supplementEntity.timeZone,
    );