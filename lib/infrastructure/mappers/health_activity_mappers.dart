import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_activity_type_mapping.dart';

/// Maps a HealthActivity from the health platform to a SportEventSimple
/// suitable for upload to the AWS backend.
SportEventSimple mapHealthActivityToSportEventSimple({
  required HealthActivity activity,
  required String userId,
  required int sportId,
  required SportsInfoEntity sportsInfo,
}) {
  final sport = HealthActivityTypeMapping.findSportById(sportId, sportsInfo);
  final intensity = HealthActivityTypeMapping.inferIntensity(
    activity.caloriesBurned,
    activity.durationMinutes,
    activity.avgHeartRate?.toDouble(),
  );

  // Use midnight of the start day, matching manual entry convention
  final startDay = DateTime(activity.startTime.year, activity.startTime.month, activity.startTime.day);
  return SportEventSimple(
    userId: userId,
    eventDate: startDay.millisecondsSinceEpoch,
    sportName: sport?.en ?? activity.activityType,
    source: activity.sourceType,
    info: [
      SportInfo(
        id: sportId,
        name_en: sport?.en ?? activity.activityType,
        name_es: sport?.es ?? activity.activityType,
        timeStart: activity.startTime.millisecondsSinceEpoch,
        intensity: intensity,
        minutes: activity.durationMinutes,
        distance: activity.distance,
        avgHeartRate: activity.avgHeartRate,
      ),
    ],
  );
}

/// Maps a HealthActivity to a SportEventComplete for local storage.
/// Used when the event has been uploaded and we have a server-assigned eventId.
SportEventComplete mapHealthActivityToSportEventComplete({
  required HealthActivity activity,
  required String userId,
  required int eventId,
  required int sportId,
  required SportsInfoEntity sportsInfo,
  required int eventKcals,
}) {
  final sport = HealthActivityTypeMapping.findSportById(sportId, sportsInfo);
  final intensity = HealthActivityTypeMapping.inferIntensity(
    activity.caloriesBurned,
    activity.durationMinutes,
    activity.avgHeartRate?.toDouble(),
  );

  // Use midnight of the start day, matching manual entry convention
  final startDay = DateTime(activity.startTime.year, activity.startTime.month, activity.startTime.day);
  return SportEventComplete(
    userId: userId,
    eventId: eventId,
    eventDate: startDay.millisecondsSinceEpoch,
    sportName: sport?.en ?? activity.activityType,
    source: activity.sourceType,
    eventKcals: eventKcals,
    info: [
      SportEventInfo(
        id: sportId,
        name_en: sport?.en ?? activity.activityType,
        name_es: sport?.es ?? activity.activityType,
        intensity: intensity,
        minutes: activity.durationMinutes,
        timeStart: activity.startTime.millisecondsSinceEpoch,
        kcal: eventKcals,
        distance: activity.distance,
        avgHeartRate: activity.avgHeartRate,
      ),
    ],
  );
}

/// Maps health sync metadata between domain and entity.
HealthSyncMetadataEntity mapToHealthSyncMetadataEntity(HealthSyncMetadata metadata) {
  return HealthSyncMetadataEntity(
    healthPlatformId: metadata.healthPlatformId,
    sportEventId: metadata.sportEventId,
    syncedAt: metadata.syncedAt.millisecondsSinceEpoch,
    sourceType: metadata.sourceType,
    normalizedType: metadata.normalizedType,
    startTimeMs: metadata.startTimeMs,
    endTimeMs: metadata.endTimeMs,
    sourceCategory: metadata.sourceCategory,
  );
}

/// Maps entity to domain model.
HealthSyncMetadata mapToHealthSyncMetadata(HealthSyncMetadataEntity entity) {
  return HealthSyncMetadata(
    healthPlatformId: entity.healthPlatformId,
    sportEventId: entity.sportEventId,
    syncedAt: DateTime.fromMillisecondsSinceEpoch(entity.syncedAt),
    sourceType: entity.sourceType,
    normalizedType: entity.normalizedType,
    startTimeMs: entity.startTimeMs,
    endTimeMs: entity.endTimeMs,
    sourceCategory: entity.sourceCategory,
  );
}
