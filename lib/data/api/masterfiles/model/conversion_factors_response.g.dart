// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_factors_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionFactorsResponse _$ConversionFactorsResponseFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorsResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => ConversionFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorsResponseToJson(
        ConversionFactorsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactor _$ConversionFactorFromJson(Map<String, dynamic> json) =>
    ConversionFactor(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ConversionFactorToJson(ConversionFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
