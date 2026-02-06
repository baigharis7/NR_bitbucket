import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'sport_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventSimple {
  String? userId;
  int? eventId;
  int? eventDate;
  List<SportInfo>? info;
  String? comment;
  String? sportName;
  String? source; // 'manual', 'apple_health', 'health_connect'

  SportEventSimple({this.userId, this.eventId, this.eventDate, this.info, this.comment, this.sportName, this.source});
  SportEventSimple.empty() {
    userId = null;
    eventId = null;
    info = <SportInfo>[];
    source = null;
  }

  factory SportEventSimple.fromJson(Map<String, dynamic> json) => _$SportEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportInfo extends Translatable {
  int? id;
  String? name_en;
  String? name_es;
  int? timeStart;
  int? intensity;
  int? minutes;
  double? distance; // in meters
  int? avgHeartRate; // in bpm

  SportInfo({
    this.id,
    this.name_en,
    this.name_es,
    this.timeStart,
    this.intensity,
    this.minutes,
    this.distance,
    this.avgHeartRate,
  });
  SportInfo.empty() {
    id = null;
    name_en = null;
    name_es = null;
    timeStart = null;
    intensity = null;
    minutes = null;
    distance = null;
    avgHeartRate = null;
  }

  factory SportInfo.fromJson(Map<String, dynamic> json) => _$SportInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoToJson(this);

}