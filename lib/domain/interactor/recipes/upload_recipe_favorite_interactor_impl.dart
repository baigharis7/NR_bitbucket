import 'package:nutrenaissance_flutter/domain/interactor/recipes/upload_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

import '../../models/recipes/upload_recipe_favorite.dart';

class UploadRecipeFavoriteInteractorImpl extends UploadRecipeFavoriteInteractor {
  final RecipesRepository recipesRepository;

  UploadRecipeFavoriteInteractorImpl({required this.recipesRepository});
  @override
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite) => recipesRepository.uploadRecipeFavorite(uploadRecipeFavorite);

}