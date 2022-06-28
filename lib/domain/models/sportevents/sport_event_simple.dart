import 'package:json_annotation/json_annotation.dart';

part 'sport_event_simple.g.dart';

@JsonSerializable(explicitToJson: true)
class SportEventSimple {
  String? userId;
  SportInfo? info;

  SportEventSimple({this.userId, this.info});
  SportEventSimple.empty() {
    userId = null;
    info = SportInfo.empty();
  }

  factory SportEventSimple.fromJson(Map<String, dynamic> json) => _$SportEventSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$SportEventSimpleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportInfo {
  int? id;
  int? timeStart;
  int? intensity;
  int? minutes;

  SportInfo({this.id, this.timeStart, this.intensity, this.minutes});
  SportInfo.empty() {
    id = null;
    timeStart = null;
    intensity = null;
    minutes = null;
  }

  factory SportInfo.fromJson(Map<String, dynamic> json) => _$SportInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoToJson(this);

}