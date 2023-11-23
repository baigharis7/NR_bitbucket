import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

import '../../../models/favorites/sport/add_sport_favorite.dart';

class GetSportFavoritesInteractorImpl extends GetSportFavoritesInteractor {
  final FavoritesRepository favoritesRepository;

  GetSportFavoritesInteractorImpl({required this.favoritesRepository});

  @override
  Future<List<AddSportFavorite>> execute() async => await favoritesRepository.getSportFavorites();

}