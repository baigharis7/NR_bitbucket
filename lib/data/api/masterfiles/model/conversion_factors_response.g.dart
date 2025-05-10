// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_factors_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionFactorsResponse _$ConversionFactorsResponseFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorsResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
          ConversionFactorResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorsResponseToJson(
    ConversionFactorsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactorResponse _$ConversionFactorResponseFromJson(
        Map<String, dynamic> json) =>
    ConversionFactorResponse(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ConversionFactorResponseToJson(
    ConversionFactorResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
