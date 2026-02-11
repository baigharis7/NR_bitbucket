// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsResponse _$CookingMethodsResponseFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodGroupResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsResponseToJson(
        CookingMethodsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodGroupResponse _$CookingMethodGroupResponseFromJson(
        Map<String, dynamic> json) =>
    CookingMethodGroupResponse(
      g: json['g'] as String,
      m: (json['m'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$CookingMethodGroupResponseToJson(
        CookingMethodGroupResponse instance) =>
    <String, dynamic>{
      'g': instance.g,
      'm': instance.m,
    };
