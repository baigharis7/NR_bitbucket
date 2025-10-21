import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';

abstract class SaveSupplementFavoriteInteractor {
  Future<void> execute(SupplementFavorite supplementFavorite, bool isEdit);
}