// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_oils_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsOilsInfoResponse _$CookingMethodsOilsInfoResponseFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsOilsInfoResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodOilInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsOilsInfoResponseToJson(
        CookingMethodsOilsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodOilInfoResponse _$CookingMethodOilInfoResponseFromJson(
        Map<String, dynamic> json) =>
    CookingMethodOilInfoResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CookingMethodOilInfoResponseToJson(
        CookingMethodOilInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'percentage': instance.percentage,
    };
