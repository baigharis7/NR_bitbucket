import 'package:json_annotation/json_annotation.dart';

part 'objectives_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ObjectivesInfoResponse {
  int v;
  List<ObjectiveInfo> data;
  List<ObjectiveInfo> metabolicObjectives;
  List<ObjectiveInfo> bodyCompositionObjectives;

  ObjectivesInfoResponse({required this.v, required this.data, required this.metabolicObjectives, required this.bodyCompositionObjectives});

  factory ObjectivesInfoResponse.fromJson(Map<String, dynamic> json) => _$ObjectivesInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectivesInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ObjectiveInfo {
  int id;
  String en;
  String es;

  ObjectiveInfo({required this.id, required this.en, required this.es});

  factory ObjectiveInfo.fromJson(Map<String, dynamic> json) => _$ObjectiveInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectiveInfoToJson(this);
}