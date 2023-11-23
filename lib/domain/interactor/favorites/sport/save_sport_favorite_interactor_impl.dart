import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class SaveSportFavoriteInteractorImpl extends SaveSportFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  SaveSportFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(AddSportFavorite addSportFavorite, bool isEdit) async => await favoritesRepository.saveSportFavorite(addSportFavorite, isEdit);

}