import 'package:json_annotation/json_annotation.dart';

part 'conversion_factors_info_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversionFactorsInfoResponse {
  int v;
  List<ConversionFactorInfoResponse> data;

  ConversionFactorsInfoResponse({required this.v, required this.data});

  factory ConversionFactorsInfoResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorsInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorsInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversionFactorInfoResponse {
  int id;
  String value;
  List<ConversionFactorResponse> list;

  ConversionFactorInfoResponse({required this.id, required this.value, required this.list});

  factory ConversionFactorInfoResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorInfoResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversionFactorResponse {
  String g;
  num v;

  ConversionFactorResponse({required this.g, required this.v});

  factory ConversionFactorResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorResponseToJson(this);
}