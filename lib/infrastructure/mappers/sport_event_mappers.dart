import 'package:nutrenaissance_flutter/data/api/sportevents/model/sport_event_response.dart' as response;
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

SportEventComplete mapToSportEventCompleteFromResponse(response.SportEventResponse sportEventResponse) {
  final sportEventComplete = SportEventComplete(
      userId: sportEventResponse.userId,
      eventDate: sportEventResponse.eventDate,
      info: SportEventInfo(
        id: sportEventResponse.info.id,
        kcal: sportEventResponse.info.kcal,
        minutes: sportEventResponse.info.minutes,
        intensity: sportEventResponse.info.intensity,
      )
  );

  return sportEventComplete;
}

SportEventEntity mapToSportEventEntity(SportEventComplete sportEventComplete) {
  final SportEventEntity sportEventEntity = SportEventEntity(
      userId: sportEventComplete.userId,
      eventDate: sportEventComplete.eventDate,
      info: SportEventInfoEntity(
        id: sportEventComplete.info.id,
        intensity: sportEventComplete.info.intensity,
        minutes: sportEventComplete.info.minutes,
        kcal: sportEventComplete.info.kcal
      ),
  );

  return sportEventEntity;
}