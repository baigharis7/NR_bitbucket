import 'package:json_annotation/json_annotation.dart';

part 'upload_supplement_routine.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadSupplementRoutine {
  String userId;
  int eventId;
  int eventDate;
  List<UploadSupplementRoutineInfo> info;
  String? name;
  String time;
  List<int> daysOfWeek;
  String timeZone;

  UploadSupplementRoutine({
    required this.userId,
    required this.eventId,
    required this.eventDate,
    required this.info,
    this.name,
    required this.time,
    required this.daysOfWeek,
    required this.timeZone,
  });

  factory UploadSupplementRoutine.fromJson(Map<String, dynamic> json) => _$UploadSupplementRoutineFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementRoutineToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UploadSupplementRoutineInfo {
  int id;
  int amount;
  String unit;

  UploadSupplementRoutineInfo({required this.id, required this.amount, required this.unit});

  factory UploadSupplementRoutineInfo.fromJson(Map<String, dynamic> json) => _$UploadSupplementRoutineInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementRoutineInfoToJson(this);
}