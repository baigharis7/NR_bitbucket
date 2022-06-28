import 'package:json_annotation/json_annotation.dart';

part 'sports_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SportsInfoResponse {
  int v;
  List<SportInfoResponse> data;
  
  SportsInfoResponse({required this.v, required this.data});

  factory SportsInfoResponse.fromJson(Map<String, dynamic> json) => _$SportsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportInfoResponse {
  int id;
  String en;
  String es;
  int mets;

  SportInfoResponse({required this.id, required this.en, required this.es, required this.mets});

  factory SportInfoResponse.fromJson(Map<String, dynamic> json) => _$SportInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoResponseToJson(this);

}

