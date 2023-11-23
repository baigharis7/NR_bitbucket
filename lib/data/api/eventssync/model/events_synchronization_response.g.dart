// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_synchronization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsSynchronizationResponse _$EventsSynchronizationResponseFromJson(
        Map<String, dynamic> json) =>
    EventsSynchronizationResponse(
      foodEvents: (json['foodEvents'] as List<dynamic>)
          .map((e) => UploadFoodEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      sportEvents: (json['sportEvents'] as List<dynamic>)
          .map((e) => SportEventComplete.fromJson(e as Map<String, dynamic>))
          .toList(),
      liquidEvents: (json['liquidEvents'] as List<dynamic>)
          .map((e) => UploadLiquidEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      waterEvents: (json['waterEvents'] as List<dynamic>)
          .map((e) => WaterEventMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodFavorites: (json['foodFavorites'] as List<dynamic>)
          .map((e) => FoodFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      sportFavorites: (json['sportFavorites'] as List<dynamic>)
          .map((e) => AddSportFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      liquidFavorites: (json['liquidFavorites'] as List<dynamic>)
          .map((e) => LiquidFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjectiveAnalysis: (json['subjectiveAnalysis'] as List<dynamic>)
          .map((e) =>
              SubjectiveAnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventsSynchronizationResponseToJson(
        EventsSynchronizationResponse instance) =>
    <String, dynamic>{
      'foodEvents': instance.foodEvents.map((e) => e.toJson()).toList(),
      'sportEvents': instance.sportEvents.map((e) => e.toJson()).toList(),
      'liquidEvents': instance.liquidEvents.map((e) => e.toJson()).toList(),
      'waterEvents': instance.waterEvents.map((e) => e.toJson()).toList(),
      'foodFavorites': instance.foodFavorites.map((e) => e.toJson()).toList(),
      'sportFavorites': instance.sportFavorites.map((e) => e.toJson()).toList(),
      'liquidFavorites':
          instance.liquidFavorites.map((e) => e.toJson()).toList(),
      'subjectiveAnalysis':
          instance.subjectiveAnalysis.map((e) => e.toJson()).toList(),
    };
