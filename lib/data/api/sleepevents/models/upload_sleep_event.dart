import 'package:json_annotation/json_annotation.dart';

part 'upload_sleep_event.g.dart';

@JsonSerializable()
class UploadSleepEvent {
  String? userId;
  int? eventId;
  int? eventDate;
  int? sleepMinutes;

  UploadSleepEvent({
    required this.userId,
    required this.eventId,
    required this.eventDate,
    required this.sleepMinutes,
  });

  factory UploadSleepEvent.fromJson(Map<String, dynamic> json) =>
      _$UploadSleepEventFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSleepEventToJson(this);
}
