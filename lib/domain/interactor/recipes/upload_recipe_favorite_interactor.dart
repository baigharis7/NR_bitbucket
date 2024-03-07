import '../../models/recipes/upload_recipe_favorite.dart';

abstract class UploadRecipeFavoriteInteractor {
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite);
}