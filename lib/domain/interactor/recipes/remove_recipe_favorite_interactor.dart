import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';

abstract class RemoveRecipeFavoriteInteractor {
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite);
}