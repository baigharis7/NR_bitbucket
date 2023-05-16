import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class AddFavoriteSportState {
  bool isLoading;
  ErrorTypes? onError;
  SportsInfoMaster? sportsInfo;
  SportFavorite? sportFavorite;
  String? timeStart;
  bool? isEdit;

  AddFavoriteSportState({
    required this.isLoading,
    this.onError,
    this.sportsInfo,
    this.sportFavorite,
    this.timeStart,
    this.isEdit,
  });

  AddFavoriteSportState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SportsInfoMaster? sportsInfo,
    SportFavorite? sportFavorite,
    String? timeStart,
    bool? isEdit,
  }) {
    return AddFavoriteSportState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      sportFavorite: sportFavorite ?? this.sportFavorite,
      timeStart: timeStart ?? this.timeStart,
      isEdit: isEdit ?? this.isEdit,
    );
  }
}
