import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'sport_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventSimple {
  String? userId;
  int? eventId;
  List<SportInfo>? info;
  String? comment;

  SportEventSimple({this.userId, this.eventId, this.info, this.comment});
  SportEventSimple.empty() {
    userId = null;
    eventId = null;
    info = <SportInfo>[];
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

  SportInfo({
    this.id,
    this.name_en,
    this.name_es,
    this.timeStart,
    this.intensity,
    this.minutes,
  });
  SportInfo.empty() {
    id = null;
    name_en = null;
    name_es = null;
    timeStart = null;
    intensity = null;
    minutes = null;
  }

  factory SportInfo.fromJson(Map<String, dynamic> json) => _$SportInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoToJson(this);

}