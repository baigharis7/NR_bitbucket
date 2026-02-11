// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sports_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportsInfoMaster _$SportsInfoMasterFromJson(Map<String, dynamic> json) =>
    SportsInfoMaster(
      sportsInfoMaster: (json['sportsInfoMaster'] as List<dynamic>)
          .map((e) => SportInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportsInfoMasterToJson(SportsInfoMaster instance) =>
    <String, dynamic>{
      'sportsInfoMaster':
          instance.sportsInfoMaster.map((e) => e.toJson()).toList(),
    };

SportInfoMaster _$SportInfoMasterFromJson(Map<String, dynamic> json) =>
    SportInfoMaster(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
      mets: (json['mets'] as num).toInt(),
    );

Map<String, dynamic> _$SportInfoMasterToJson(SportInfoMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'mets': instance.mets,
    };
