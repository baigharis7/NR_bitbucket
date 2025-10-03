import '../../../data/api/supplements/model/supplement_favorite.dart';

abstract class UploadSupplementFavoriteInteractor {
  Future<void> execute(SupplementFavorite supplementFavorite);
}