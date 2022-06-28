import 'package:json_annotation/json_annotation.dart';

part 'sport_event_complete.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventComplete {
  String userId;
  int eventDate;
  SportEventInfo info;

  SportEventComplete({required this.userId, required this.eventDate, required this.info});

  factory SportEventComplete.fromJson(Map<String, dynamic> json) => _$SportEventCompleteFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventCompleteToJson(this);

}

@JsonSerializable(explicitToJson: true)
class SportEventInfo {
  int id;
  int intensity;
  int minutes;
  int kcal;

  SportEventInfo({required this.id, required this.intensity, required this.minutes, required this.kcal, });

  factory SportEventInfo.fromJson(Map<String, dynamic> json) => _$SportEventInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoToJson(this);

}