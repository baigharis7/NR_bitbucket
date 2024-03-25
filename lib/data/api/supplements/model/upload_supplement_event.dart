import 'package:json_annotation/json_annotation.dart';
part 'upload_supplement_event.g.dart';
@JsonSerializable(explicitToJson: true)
class UploadSupplementEvent {
  String? userId;
  int? eventId;
  int? value;

  UploadSupplementEvent({required this.userId, required this.eventId, required this.value});

  factory UploadSupplementEvent.fromJson(Map<String, dynamic> json) => _$UploadSupplementEventFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementEventToJson(this);
}