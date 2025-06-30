import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

SportRoutineEntity mapToSportRoutineEntity(
  SportRoutineCompleted sportRoutineCompleted,
) {
  return SportRoutineEntity(
    userId: sportRoutineCompleted.userId,
    eventId: sportRoutineCompleted.eventId,
    eventDate: sportRoutineCompleted.eventDate,
    comment: sportRoutineCompleted.comment,
    sportName: sportRoutineCompleted.sportName,
    scheduleTime: sportRoutineCompleted.scheduleTime,
    info: sportRoutineCompleted.info.orEmpty().map((sRoutineInfo) => SportRoutineInfoEntity(id: sRoutineInfo.id, nameEn:  sRoutineInfo.nameEn, nameEs:  sRoutineInfo.nameEs, timeStart:  sRoutineInfo.timeStart, intensity:  sRoutineInfo.intensity, minutes:  sRoutineInfo.minutes)).toList(),
    daysOfWeek: sportRoutineCompleted.daysOfWeek,
    timeZone: sportRoutineCompleted.timeZone,
  );
}

SportRoutineCompleted mapToSportRoutineCompleted(SportRoutineEntity sportRoutineEntity) => SportRoutineCompleted(
  userId: sportRoutineEntity.userId,
  eventId: sportRoutineEntity.eventId,
  eventDate: sportRoutineEntity.eventDate,
  comment: sportRoutineEntity.comment,
  sportName: sportRoutineEntity.sportName,
  info: sportRoutineEntity.info.orEmpty().map((sRoutineEntity) => Info(id: sRoutineEntity.id, nameEn: sRoutineEntity.nameEn, nameEs: sRoutineEntity.nameEs, minutes: sRoutineEntity.minutes, intensity: sRoutineEntity.intensity, timeStart: sRoutineEntity.timeStart,)).toList(),
  scheduleTime: sportRoutineEntity.scheduleTime,
  daysOfWeek: sportRoutineEntity.daysOfWeek,
  timeZone: sportRoutineEntity.timeZone,
);
