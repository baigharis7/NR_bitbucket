import 'package:nutrenaissance_flutter/data/api/sportevents/model/sport_event_response.dart' as response;
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

SportEventComplete mapToSportEventCompleteFromResponse(response.SportEventResponse sportEventResponse) {
  final sportEventComplete = SportEventComplete(
    userId: sportEventResponse.userId,
    eventDate: sportEventResponse.eventDate,
    eventKcal: sportEventResponse.eventKcal,
    info: SportEventInfo(
      id: sportEventResponse.info.id,
      name_en: sportEventResponse.info.name_en,
      name_es: sportEventResponse.info.name_es,
      kcal: sportEventResponse.info.kcal,
      minutes: sportEventResponse.info.minutes,
      intensity: sportEventResponse.info.intensity,
    ),
  );

  return sportEventComplete;
}

SportEventEntity mapToSportEventEntity(SportEventComplete sportEventComplete) {
  final SportEventEntity sportEventEntity = SportEventEntity(
    userId: sportEventComplete.userId,
    eventDate: sportEventComplete.eventDate,
    eventKcal: sportEventComplete.eventKcal,
    info: SportEventInfoEntity(
      id: sportEventComplete.info.id,
      name_en: sportEventComplete.info.name_en,
      name_es: sportEventComplete.info.name_es,
      intensity: sportEventComplete.info.intensity,
      minutes: sportEventComplete.info.minutes,
      kcal: sportEventComplete.info.kcal,
    ),
  );

  return sportEventEntity;
}

SportEventComplete mapToSportEventComplete(SportEventEntity entity) {
  final SportEventComplete sportEventComplete = SportEventComplete(
    userId: entity.userId,
    eventDate: entity.eventDate,
    info: SportEventInfo(
      id: entity.info.id,
      name_en: entity.info.name_en.orEmpty(),
      name_es: entity.info.name_es.orEmpty(),
      intensity: entity.info.intensity,
      minutes: entity.info.minutes,
      kcal: entity.info.kcal,
    ),
    eventKcal: entity.eventKcal,
  );

  return sportEventComplete;

}