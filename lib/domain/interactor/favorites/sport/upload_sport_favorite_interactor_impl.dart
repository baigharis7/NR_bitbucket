import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class UploadSportFavoriteInteractorImpl extends UploadSportFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  UploadSportFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(AddSportFavorite sportFavorite) async => favoritesRepository.uploadSportFavorite(sportFavorite);

}