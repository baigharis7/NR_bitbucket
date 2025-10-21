import 'package:json_annotation/json_annotation.dart';

part 'upload_supplements_ev.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadSupplementsEv {
  String userId;
  int eventId;
  int eventDate;
  List<UploadSupplementInfo> info;
  String? name;

  UploadSupplementsEv({required this.userId, required this.eventId, required this.eventDate, required this.info, this.name});

  factory UploadSupplementsEv.fromJson(Map<String, dynamic> json) => _$UploadSupplementsEvFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementsEvToJson(this);
}

class UploadSupplementInfo {
  int id;
  int amount;
  String unit;

  UploadSupplementInfo({required this.id, required this.amount, required this.unit});
  factory UploadSupplementInfo.fromJson(Map<String, dynamic> json) => _$UploadSupplementInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UploadSupplementInfoToJson(this);
}
