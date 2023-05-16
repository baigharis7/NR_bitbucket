import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class SportFavoritesState {
  bool isLoading;
  ErrorTypes? onError;
  List<SportFavorite>? sportFavorites;
  bool? showCard;

  SportFavoritesState({
    required this.isLoading,
    this.onError,
    this.sportFavorites,
    this.showCard,
  });

  SportFavoritesState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<SportFavorite>? sportFavorites,
    bool? showCard,
  }) {
    return SportFavoritesState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportFavorites: sportFavorites ?? this.sportFavorites,
      showCard: showCard ?? this.showCard,
    );
  }
}