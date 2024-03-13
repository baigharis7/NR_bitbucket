import 'package:json_annotation/json_annotation.dart';

part 'upload_feces.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadFeces {
  String userId;
  int eventId;
  int fecesId;

  UploadFeces({required this.userId, required this.eventId, required this.fecesId});

  factory UploadFeces.fromJson(Map<String, dynamic> json) => _$UploadFecesFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFecesToJson(this);
}