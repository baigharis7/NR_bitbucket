import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

part 'events_synchronization_response.g.dart';

@JsonSerializable(explicitToJson: true)
class EventsSynchronizationResponse {
  List<UploadFoodEvent> foodEvents;
  List<SportEventComplete> sportEvents;
  List<UploadLiquidEvent> liquidEvents;
  List<WaterEventMaster> waterEvents;
  List<FoodFavorite> foodFavorites;
  List<SportFavorite> sportFavorites;
  List<LiquidFavorite> liquidFavorites;
  List<SubjectiveAnalysisResult> subjectiveAnalysis;

  EventsSynchronizationResponse({
    required this.foodEvents,
    required this.sportEvents,
    required this.liquidEvents,
    required this.waterEvents,
    required this.foodFavorites,
    required this.sportFavorites,
    required this.liquidFavorites,
    required this.subjectiveAnalysis,
  });

  factory EventsSynchronizationResponse.fromJson(Map<String, dynamic> json) => _$EventsSynchronizationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EventsSynchronizationResponseToJson(this);
}