import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'sport_event_complete.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventComplete {
  String userId;
  int eventDate;
  SportEventInfo info;
  int? eventKcal;

  SportEventComplete({
    required this.userId,
    required this.eventDate,
    required this.info,
    required this.eventKcal,
  });

  factory SportEventComplete.fromJson(Map<String, dynamic> json) => _$SportEventCompleteFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventCompleteToJson(this);

}

@JsonSerializable(explicitToJson: true)
class SportEventInfo extends Translatable {
  int id;
  String name_en;
  String name_es;
  int intensity;
  int minutes;
  int kcal;

  SportEventInfo({
    required this.id,
    required this.name_en,
    required this.name_es,
    required this.intensity,
    required this.minutes,
    required this.kcal,
  });

  factory SportEventInfo.fromJson(Map<String, dynamic> json) => _$SportEventInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventInfoToJson(this);

}