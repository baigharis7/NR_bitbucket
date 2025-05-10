// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_factors_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversionFactorsInfoResponse _$ConversionFactorsInfoResponseFromJson(
    Map<String, dynamic> json) =>
    ConversionFactorsInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
          ConversionFactorInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorsInfoResponseToJson(
    ConversionFactorsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactorInfoResponse _$ConversionFactorInfoResponseFromJson(
    Map<String, dynamic> json) =>
    ConversionFactorInfoResponse(
      id: json['id'] as int,
      value: json['value'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
          ConversionFactorResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversionFactorInfoResponseToJson(
    ConversionFactorInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ConversionFactorResponse _$ConversionFactorResponseFromJson(
    Map<String, dynamic> json) =>
    ConversionFactorResponse(
      g: json['g'] as String,
      v: json['v'] as int,
    );

Map<String, dynamic> _$ConversionFactorResponseToJson(
    ConversionFactorResponse instance) =>
    <String, dynamic>{
      'g': instance.g,
      'v': instance.v,
    };