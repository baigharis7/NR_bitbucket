import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

import '../../../data/api/sportevents/model/sport_event_response.dart';

part 'sport_event_complete.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventComplete {
  String userId;
  int eventId;
  int eventDate;
  String? comment;
  String? sportName;
  List<SportEventInfo>? info;
  int? eventKcals;
  String? source; // 'manual', 'apple_health', 'health_connect'

  SportEventComplete({
    required this.userId,
    required this.eventId,
    required this.eventDate,
    this.comment,
    this.sportName,
    required this.info,
    this.eventKcals,
    this.source,
  });

  factory SportEventComplete.fromJson(Map<String, dynamic> json) => _$SportEventCompleteFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventCompleteToJson(this);

}

@JsonSerializable(explicitToJson: true)
class SportEventInfo extends Translatable {
  int id;
  String? name_en;
  String? name_es;
  int? intensity;
  int minutes;
  int? timeStart;
  int? kcal;
  double? distance; // in meters
  int? avgHeartRate; // in bpm

  SportEventInfo({
    required this.id,
    this.name_en,
    this.name_es,
    this.intensity,
    required this.minutes,
    this.timeStart,
    this.kcal,
    this.distance,
    this.avgHeartRate,
  });

  factory SportEventInfo.fromJson(Map<String, dynamic> json) => _$SportEventInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoToJson(this);

}