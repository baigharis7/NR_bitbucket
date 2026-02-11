// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdviceResponse _$AdviceResponseFromJson(Map<String, dynamic> json) =>
    AdviceResponse(
      id: (json['id'] as num).toInt(),
      adv_es: json['adv_es'] as String,
      adv_en: json['adv_en'] as String?,
      objective: (json['objective'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      interaction: (json['interaction'] as num).toInt(),
    );

Map<String, dynamic> _$AdviceResponseToJson(AdviceResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adv_es': instance.adv_es,
      'adv_en': instance.adv_en,
      'objective': instance.objective,
      'interaction': instance.interaction,
    };
