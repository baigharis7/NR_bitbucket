// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_synchronization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsSynchronizationResponse _$EventsSynchronizationResponseFromJson(
        Map<String, dynamic> json) =>
    EventsSynchronizationResponse(
      foodEvents: (json['foodEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadFoodEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodRoutines: (json['foodRoutines'] as List<dynamic>?)
          .orEmpty().safeMap((e) => FoodRoutineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      sportEvents: (json['sportEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => SportEventComplete.fromJson(e as Map<String, dynamic>))
          .toList(),
      // sportRoutines: [],
          sportRoutines: (json['sportRoutines'] as List<dynamic>?)
          .orEmpty().safeMap((e) => SportRoutineCompleted.fromJson(e as Map<String, dynamic>))
          .toList(),
      liquidEvents: (json['liquidEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadLiquidEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      waterEvents: (json['waterEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => WaterEventMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodFavorites: (json['foodFavorites'] as List<dynamic>?)
          .orEmpty().safeMap((e) => FoodFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      sportFavorites: (json['sportFavorites'] as List<dynamic>?)
          .orEmpty().safeMap((e) => AddSportFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      liquidFavorites: (json['liquidFavorites'] as List<dynamic>?)
          .orEmpty().safeMap((e) => LiquidFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjectiveAnalysis: (json['subjectiveAnalysis'] as List<dynamic>?)
          .orEmpty().safeMap((e) =>
              SubjectiveAnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      recipeFavorites: (json['recipeFavorites'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadRecipeFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      fecesEvents: (json['fecesEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadFeces.fromJson(e as Map<String, dynamic>))
          .toList(),
      urineEvents: (json['urineEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadFeces.fromJson(e as Map<String, dynamic>))
          .toList(),
      creatineEvents: (json['creatineEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadSupplementEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      collagenEvents: (json['collagenEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadSupplementEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      supplementEvents: (json['supplementEvents'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadSupplementsEv.fromJson(e as Map<String, dynamic>))
          .toList(),
      supplementFavorites: (json['supplementFavorites'] as List<dynamic>?)
          .orEmpty().safeMap((e) => SupplementFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      supplementRoutines: (json['supplementRoutines'] as List<dynamic>?)
          .orEmpty().safeMap((e) => UploadSupplementRoutine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventsSynchronizationResponseToJson(
        EventsSynchronizationResponse instance) =>
    <String, dynamic>{
      'foodEvents': instance.foodEvents.map((e) => e.toJson()).toList(),
      'sportEvents': instance.sportEvents.map((e) => e.toJson()).toList(),
      'sportRoutines': instance.sportRoutines.map((e) => e.toJson()).toList(),
      'liquidEvents': instance.liquidEvents.map((e) => e.toJson()).toList(),
      'waterEvents': instance.waterEvents.map((e) => e.toJson()).toList(),
      'foodFavorites': instance.foodFavorites.map((e) => e.toJson()).toList(),
      'sportFavorites': instance.sportFavorites.map((e) => e.toJson()).toList(),
      'liquidFavorites':
          instance.liquidFavorites.map((e) => e.toJson()).toList(),
      'subjectiveAnalysis':
          instance.subjectiveAnalysis.map((e) => e.toJson()).toList(),
      'recipeFavorites':
          instance.recipeFavorites.map((e) => e.toJson()).toList(),
      'fecesEvents': instance.fecesEvents.map((e) => e.toJson()).toList(),
      'urineEvents': instance.urineEvents.map((e) => e.toJson()).toList(),
      'creatineEvents': instance.creatineEvents.map((e) => e.toJson()).toList(),
      'collagenEvents': instance.collagenEvents.map((e) => e.toJson()).toList(),
      'supplementEvents': instance.supplementEvents.map((e) => e.toJson()).toList(),
      'supplementFavorites': instance.supplementFavorites.map((e) => e.toJson()).toList(),
      'supplementRoutines': instance.supplementRoutines.map((e) => e.toJson()).toList(),
    };
