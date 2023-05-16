import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class UploadSportFavoriteInteractorImpl extends UploadSportFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  UploadSportFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(SportFavorite sportFavorite, String userId) async => favoritesRepository.uploadSportFavorite(sportFavorite, userId);

}