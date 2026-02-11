// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Advice _$AdviceFromJson(Map<String, dynamic> json) => Advice(
      id: (json['id'] as num).toInt(),
      advEs: json['advEs'] as String,
      advEn: json['advEn'] as String?,
      objective: (json['objective'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      interaction: (json['interaction'] as num).toInt(),
    );

Map<String, dynamic> _$AdviceToJson(Advice instance) => <String, dynamic>{
      'id': instance.id,
      'advEs': instance.advEs,
      'advEn': instance.advEn,
      'objective': instance.objective,
      'interaction': instance.interaction,
    };
