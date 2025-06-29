import 'package:nutrenaissance_flutter/data/api/sportevents/model/sport_event_response.dart' as response;
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

SportEventComplete mapToSportEventCompleteFromResponse(response.SportEventResponse sportEventResponse) {
  final sportEventComplete = SportEventComplete(
    userId: sportEventResponse.userId,
    eventId: sportEventResponse.eventId,
    eventDate: sportEventResponse.eventDate,
    comment: sportEventResponse.comment,
    sportName: sportEventResponse.sportName,
    eventKcals: sportEventResponse.eventKcal,
    info: sportEventResponse.info?.map((sportEventResponse) => SportEventInfo(
      id: sportEventResponse.id,
      name_en: sportEventResponse.name_en,
      name_es: sportEventResponse.name_es,
      kcal: sportEventResponse.kcal,
      minutes: sportEventResponse.minutes,
      timeStart: sportEventResponse.timeStart,
      intensity: sportEventResponse.intensity,
    ),).toList(),
  );

  return sportEventComplete;
}

SportEventEntity mapToSportEventEntity(SportEventComplete sportEventComplete) {
  final SportEventEntity sportEventEntity = SportEventEntity(
    userId: sportEventComplete.userId,
    eventId: sportEventComplete.eventId,
    eventDate: sportEventComplete.eventDate,
    comment: sportEventComplete.comment,
    sportName: sportEventComplete.sportName,
    eventKcals: sportEventComplete.eventKcals,
    info: sportEventComplete.info?.map((sportEventComplete) => SportEventInfoEntity(
      id: sportEventComplete.id,
      name_en: sportEventComplete.name_en,
      name_es: sportEventComplete.name_es,
      intensity: sportEventComplete.intensity,
      minutes: sportEventComplete.minutes,
      timeStart: sportEventComplete.timeStart,
      kcal: sportEventComplete.kcal,
    ),).toList(),
  );

  return sportEventEntity;
}

SportEventComplete mapToSportEventComplete(SportEventEntity entity) {
  final SportEventComplete sportEventComplete = SportEventComplete(
    userId: entity.userId,
    eventId: entity.eventId,
    eventDate: entity.eventDate,
    comment: entity.comment,
    sportName: entity.sportName,
    info: entity.info?.map((entity) => SportEventInfo(
      id: entity.id,
      name_en: entity.name_en.orEmpty(),
      name_es: entity.name_es.orEmpty(),
      intensity: entity.intensity,
      minutes: entity.minutes,
      timeStart: entity.timeStart,
      kcal: entity.kcal,
    ),).toList(),
    eventKcals: entity.eventKcals,
  );

  return sportEventComplete;

}