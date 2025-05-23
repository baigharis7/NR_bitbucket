import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'conversion_factors_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversionFactorsResponse {
  int v;
  List<ConversionFactor> data;

  ConversionFactorsResponse({required this.v, required this.data});

  factory ConversionFactorsResponse.fromJson(Map<String, dynamic> json) => _$ConversionFactorsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConversionFactor extends Translatable {
  int id;
  String en;
  String es;

  ConversionFactor({required this.id, required this.en, required this.es});

  factory ConversionFactor.fromJson(Map<String, dynamic> json) => _$ConversionFactorFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorToJson(this);
}