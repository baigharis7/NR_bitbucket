import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

/// Wrapper returned by [FoodScannerScreen] to distinguish between
/// direct-logging and editing flows.
class ScannerResult {
  final List<FoodInFavorite> foods;

  /// When true, the caller should save immediately and navigate to
  /// MealTimeDetailScreen. When false, the caller should open the
  /// edit flow (AddFoodEventScreen).
  final bool directLog;

  /// Auto-generated title for the food event.
  /// Single food → food name; multiple foods → LogMeal dish name.
  final String? title;

  ScannerResult({required this.foods, required this.directLog, this.title});
}
