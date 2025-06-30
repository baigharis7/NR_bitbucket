import 'package:json_annotation/json_annotation.dart';

part 'sport_routine_completed.g.dart';
@JsonSerializable(explicitToJson: true)
class SportRoutineCompleted {
  String? userId;
  int? eventId;
  int? eventDate;
  List<Info>? info;
  String? comment;
  String? sportName;
  String? scheduleTime;
  List<int>? daysOfWeek;
  String? timeZone;

  SportRoutineCompleted({
    this.userId,
    this.eventId,
    this.eventDate,
    this.info,
    this.comment,
    this.sportName,
    this.scheduleTime,
    this.daysOfWeek,
    this.timeZone,
  });

  factory SportRoutineCompleted.fromJson(Map<String, dynamic> json) => _$SportRoutineCompletedFromJson(json);
  Map<String, dynamic> toJson() => _$SportRoutineCompletedToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Info {
  num? id;
  String? nameEn;
  String? nameEs;
  num? timeStart;
  num? intensity;
  num? minutes;

  Info({
    this.id,
    this.nameEn,
    this.nameEs,
    this.timeStart,
    this.intensity,
    this.minutes,
  });

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}
