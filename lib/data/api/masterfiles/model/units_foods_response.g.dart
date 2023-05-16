// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_foods_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsFoodsResponse _$UnitsFoodsResponseFromJson(Map<String, dynamic> json) =>
    UnitsFoodsResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => UnitFoodResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsFoodsResponseToJson(UnitsFoodsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

UnitFoodResponse _$UnitFoodResponseFromJson(Map<String, dynamic> json) =>
    UnitFoodResponse(
      id: json['id'] as int,
      units: json['units'] as String,
    );

Map<String, dynamic> _$UnitFoodResponseToJson(UnitFoodResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'units': instance.units,
    };
