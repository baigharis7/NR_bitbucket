import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class RemoveSportFavoriteInteractorImpl extends RemoveSportFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  RemoveSportFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(SportFavorite sportFavorite, String userId) async => await favoritesRepository.removeSportFavoriteFromLocal(sportFavorite, userId);

}