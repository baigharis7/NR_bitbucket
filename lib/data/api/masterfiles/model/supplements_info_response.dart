import 'package:json_annotation/json_annotation.dart';

part 'supplements_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SupplementsInfoResponse {
  int v;
  List<SupplementInfoResponse> data;

  SupplementsInfoResponse({required this.v, required this.data});

  factory SupplementsInfoResponse.fromJson(Map<String, dynamic> json) => _$SupplementsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SupplementInfoResponse {
  int id;
  String es;
  String en;
  String unit;
  String? computerName;

  SupplementInfoResponse({required this.id, required this.es, required this.en, required this.unit, this.computerName});

  factory SupplementInfoResponse.fromJson(Map<String, dynamic> json) => _$SupplementInfoResponse(json);
  Map<String, dynamic> toJson() => _$SupplementInfoResponseToJson(this);
}