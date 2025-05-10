import 'package:json_annotation/json_annotation.dart';

part 'conversion_factors_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversionFactorsResponse {
  int v;
  List<ConversionFactorResponse> data;

  ConversionFactorsResponse({required this.v, required this.data});

  factory ConversionFactorsResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversionFactorResponse {
  int id;
  String en;
  String es;

  ConversionFactorResponse({required this.id, required this.en, required this.es});

  factory ConversionFactorResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorResponseToJson(this);
}