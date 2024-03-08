import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';

abstract class SaveRecipeFavoriteInteractor {
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite);
}