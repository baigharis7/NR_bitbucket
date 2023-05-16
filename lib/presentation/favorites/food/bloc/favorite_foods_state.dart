import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class FavoriteFoodsState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodFavorite>? foodFavorites;
  bool? showCard;

  FavoriteFoodsState({
    required this.isLoading,
    this.onError,
    this.foodFavorites,
    this.showCard,
  });

  FavoriteFoodsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodFavorite>? foodFavorites,
    bool? showCard,
  }) {
    return FavoriteFoodsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodFavorites: foodFavorites ?? this.foodFavorites,
      showCard: showCard ?? this.showCard,
    );
  }
}