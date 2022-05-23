// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsInfoResponse _$CookingMethodsInfoResponseFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => CookingMethodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsInfoResponseToJson(
        CookingMethodsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodInfo _$CookingMethodInfoFromJson(Map<String, dynamic> json) =>
    CookingMethodInfo(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$CookingMethodInfoToJson(CookingMethodInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
