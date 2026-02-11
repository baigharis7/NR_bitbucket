// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsMaster _$CookingMethodsMasterFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsMaster(
      cookingMethods: (json['data'] as List<dynamic>)
          .map((e) => CookingMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsMasterToJson(
        CookingMethodsMaster instance) =>
    <String, dynamic>{
      'data': instance.cookingMethods.map((e) => e.toJson()).toList(),
    };

CookingMethod _$CookingMethodFromJson(Map<String, dynamic> json) =>
    CookingMethod(
      group: json['group'] as String,
      methods: (json['methods'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CookingMethodToJson(CookingMethod instance) =>
    <String, dynamic>{
      'group': instance.group,
      'methods': instance.methods,
    };
