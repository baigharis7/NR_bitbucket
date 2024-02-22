import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

SportRoutineEntity mapToSportRoutineEntity(
  SportRoutineCompleted sportRoutineCompleted,
) {
  return SportRoutineEntity(
    sportRoutineCompleted.userId,
    sportRoutineCompleted.eventId,
    sportRoutineCompleted.comment,
    sportRoutineCompleted.sportName,
    sportRoutineCompleted.routineTime,
    sportRoutineCompleted.info.orEmpty().map((sRoutineInfo) => SportRoutineInfoEntity(sRoutineInfo.id, sRoutineInfo.nameEn, sRoutineInfo.nameEs, sRoutineInfo.timeStart, sRoutineInfo.intensity, sRoutineInfo.minutes)).toList(),
  );
}

SportRoutineCompleted mapToSportRoutineCompleted(SportRoutineEntity sportRoutineEntity) => SportRoutineCompleted(
  userId: sportRoutineEntity.userId,
  eventId: sportRoutineEntity.eventId,
  comment: sportRoutineEntity.comment,
  sportName: sportRoutineEntity.sportName,
  routineTime: sportRoutineEntity.routineTime,
  info: sportRoutineEntity.info.orEmpty().map((sRoutineEntity) => Info(id: sRoutineEntity.id, nameEn: sRoutineEntity.nameEn, nameEs: sRoutineEntity.nameEs, minutes: sRoutineEntity.minutes, intensity: sRoutineEntity.intensity, timeStart: sRoutineEntity.timeStart,)).toList(),
);
