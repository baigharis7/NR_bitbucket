// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsMaster _$CookingMethodsMasterFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsMaster(
      json['v'] as int,
      (json['data'] as List<dynamic>)
          .map((e) => CookingMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsMasterToJson(
        CookingMethodsMaster instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethod _$CookingMethodFromJson(Map<String, dynamic> json) =>
    CookingMethod(
      json['group'] as String,
      (json['methods'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$CookingMethodToJson(CookingMethod instance) =>
    <String, dynamic>{
      'group': instance.group,
      'methods': instance.methods,
    };
