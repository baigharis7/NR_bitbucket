import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class RecommendationsState {
  bool isLoading;
  ErrorTypes? onError;
  Recommendation? recommendation;
  RecommendationGroupsMaster? recommendationGroups;
  FoodsAndDrinksNamesMaster? foodAndDrinksNames;
  List<int>? selectedFoodIds;
  List<String>? selectedFoodNames;
  bool multiSelection;
  List<RecommendationsFoodItem>? recommendationFoodsItems;
  bool? showCard;

  RecommendationsState({
    required this.isLoading, 
    this.onError,
    this.recommendation,
    this.recommendationGroups,
    this.foodAndDrinksNames,
    this.selectedFoodIds,
    this.selectedFoodNames,
    this.multiSelection = false,
    this.recommendationFoodsItems,
    this.showCard,
  });

  RecommendationsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    Recommendation? recommendation,
    RecommendationGroupsMaster? recommendationGroups,
    FoodsAndDrinksNamesMaster? foodAndDrinksNames,
    List<int>? selectedFoodIds,
    List<String>? selectedFoodNames,
    bool? multiSelection,
    List<RecommendationsFoodItem>? recommendationFoodsItems,
    bool? showCard,
  }) {
    return RecommendationsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      recommendation: recommendation ?? this.recommendation,
      recommendationGroups: recommendationGroups ?? this.recommendationGroups,
      foodAndDrinksNames: foodAndDrinksNames ?? this.foodAndDrinksNames,
      selectedFoodIds: selectedFoodIds ?? this.selectedFoodIds,
      selectedFoodNames: selectedFoodNames ?? this.selectedFoodNames,
      multiSelection: multiSelection ?? this.multiSelection,
      recommendationFoodsItems: recommendationFoodsItems ?? this.recommendationFoodsItems,
      showCard: showCard ?? this.showCard,
    );
  }

}