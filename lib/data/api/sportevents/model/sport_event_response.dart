import 'package:json_annotation/json_annotation.dart';

part 'sport_event_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventResponse {
  String userId;
  int eventId;
  String? comment;
  SportEventInfoResponse info;
  int? eventKcal;

  SportEventResponse({
    required this.userId,
    required this.eventId,
    required this.comment,
    required this.info,
    this.eventKcal,
  });

  factory SportEventResponse.fromJson(Map<String, dynamic> json) => _$SportEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportEventInfoResponse {
  int id;
  String name_en;
  String name_es;
  int intensity;
  int minutes;
  int kcal;

  SportEventInfoResponse({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.intensity,
    required this.minutes,
    required this.kcal,
  });

  factory SportEventInfoResponse.fromJson(Map<String, dynamic> json) => _$SportEventInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoResponseToJson(this);

}