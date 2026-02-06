import 'package:json_annotation/json_annotation.dart';

part 'sport_event_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventResponse {
  String userId;
  int eventId;
  int eventDate;
  String? comment;
  String? sportName;
  List<SportEventInfoResponse>? info;
  int? eventKcal;
  String? source; // 'manual', 'apple_health', 'health_connect'

  SportEventResponse({
    required this.userId,
    required this.eventId,
    required this.eventDate,
    this.comment,
    this.sportName,
    required this.info,
    this.eventKcal,
    this.source,
  });

  factory SportEventResponse.fromJson(Map<String, dynamic> json) => _$SportEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportEventInfoResponse {
  int id;
  String? name_en;
  String? name_es;
  int? intensity;
  int minutes;
  int? timeStart;
  int? kcal;
  double? distance; // in meters
  int? avgHeartRate; // in bpm

  SportEventInfoResponse({
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

  factory SportEventInfoResponse.fromJson(Map<String, dynamic> json) => _$SportEventInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoResponseToJson(this);

}