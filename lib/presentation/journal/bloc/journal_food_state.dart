import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/favorites/food/food_favorite.dart';

class JournalFoodState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? todayFoodEvents;
  List<FoodFavorite>? foodFavorites;
  List<Map<String, dynamic>>? weeklyData;
  int? userKcal;
  bool? showCard;
  String? favoriteName;
  int? mealTime;
  bool? isEdit;

  JournalFoodState({
    required this.isLoading,
    this.onError,
    this.todayFoodEvents,
    this.foodFavorites,
    this.weeklyData,
    this.userKcal,
    this.showCard,
    this.favoriteName,
    this.mealTime,
    this.isEdit
  });

  JournalFoodState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? todayFoodEvents,
    List<FoodFavorite>? foodFavorites,
    List<Map<String, dynamic>>? weeklyData,
    int? userKcal,
    bool? showCard,
    String? favoriteName,
    int? mealTime,
    bool? isEdit
  }) {
    return JournalFoodState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      todayFoodEvents: todayFoodEvents ?? this.todayFoodEvents,
      foodFavorites: foodFavorites ?? this.foodFavorites,
      weeklyData: weeklyData ?? this.weeklyData,
      userKcal: userKcal ?? this.userKcal,
      showCard: showCard ?? this.showCard,
      favoriteName:  favoriteName ?? this.favoriteName,
      mealTime: mealTime ?? this.mealTime,
      isEdit: isEdit ?? this.isEdit,
    );
  }

}