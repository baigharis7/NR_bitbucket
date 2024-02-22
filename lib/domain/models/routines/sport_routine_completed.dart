import 'package:json_annotation/json_annotation.dart';

part 'sport_routine_completed.g.dart';
@JsonSerializable(explicitToJson: true)
class SportRoutineCompleted {
  String? userId;
  int? eventId;
  String? comment;
  String? sportName;
  String? routineTime;
  List<Info>? info;

  SportRoutineCompleted({
    this.userId,
    this.eventId,
    this.comment,
    this.sportName,
    this.routineTime,
    this.info,
  });
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
}
