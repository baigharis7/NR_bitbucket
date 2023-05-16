import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class JournalFoodState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? todayFoodEvents;
  List<Map<String, dynamic>>? weeklyData;
  int? userKcal;
  bool? showCard;

  JournalFoodState({
    required this.isLoading,
    this.onError,
    this.todayFoodEvents,
    this.weeklyData,
    this.userKcal,
    this.showCard,
  });

  JournalFoodState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? todayFoodEvents,
    List<Map<String, dynamic>>? weeklyData,
    int? userKcal,
    bool? showCard,
  }) {
    return JournalFoodState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      todayFoodEvents: todayFoodEvents ?? this.todayFoodEvents,
      weeklyData: weeklyData ?? this.weeklyData,
      userKcal: userKcal ?? this.userKcal,
      showCard: showCard ?? this.showCard,
    );
  }

}