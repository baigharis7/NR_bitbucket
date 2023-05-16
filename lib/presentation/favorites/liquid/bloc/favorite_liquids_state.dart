import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class FavoriteLiquidsState {
  bool isLoading;
  ErrorTypes? onError;
  List<LiquidFavorite>? liquidFavorites;

  FavoriteLiquidsState({
    required this.isLoading,
    this.onError,
    this.liquidFavorites,
  });

  FavoriteLiquidsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<LiquidFavorite>? liquidFavorites,
  }) {
    return FavoriteLiquidsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      liquidFavorites: liquidFavorites ?? this.liquidFavorites,
    );
  }
}