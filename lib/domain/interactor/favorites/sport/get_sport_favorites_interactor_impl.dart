import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class GetSportFavoritesInteractorImpl extends GetSportFavoritesInteractor {
  final FavoritesRepository favoritesRepository;

  GetSportFavoritesInteractorImpl({required this.favoritesRepository});

  @override
  Future<List<SportFavorite>> execute() async => await favoritesRepository.getSportFavorites();

}