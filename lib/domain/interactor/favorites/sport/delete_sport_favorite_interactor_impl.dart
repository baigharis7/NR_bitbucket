import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class DeleteSportFavoriteInteractorImpl extends DeleteSportFavoriteInteractor{
  final FavoritesRepository favoritesRepository;

  DeleteSportFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(String userId, int eventId) async => await favoritesRepository.deleteSportFavoriteFromCloud(userId, eventId);

}