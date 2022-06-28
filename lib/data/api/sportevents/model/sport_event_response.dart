import 'package:json_annotation/json_annotation.dart';

part 'sport_event_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventResponse {
  String userId;
  int eventDate;
  SportEventInfoResponse info;

  SportEventResponse({required this.userId, required this.eventDate, required this.info});

  factory SportEventResponse.fromJson(Map<String, dynamic> json) => _$SportEventResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportEventInfoResponse {
  int id;
  int intensity;
  int minutes;
  int kcal;

  SportEventInfoResponse({required this.id, required this.intensity, required this.minutes, required this.kcal, });

  factory SportEventInfoResponse.fromJson(Map<String, dynamic> json) => _$SportEventInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoResponseToJson(this);

}