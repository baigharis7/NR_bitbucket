// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsInfoMaster _$CookingMethodsInfoMasterFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsInfoMaster(
      (json['cookingMethodsInfo'] as List<dynamic>?)
          ?.map((e) => CookingMethodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsInfoMasterToJson(
        CookingMethodsInfoMaster instance) =>
    <String, dynamic>{
      'cookingMethodsInfo':
          instance.cookingMethodsInfo?.map((e) => e.toJson()).toList(),
    };

CookingMethodInfo _$CookingMethodInfoFromJson(Map<String, dynamic> json) =>
    CookingMethodInfo(
      json['id'] as int?,
      json['en'] as String?,
      json['es'] as String?,
    );

Map<String, dynamic> _$CookingMethodInfoToJson(CookingMethodInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
