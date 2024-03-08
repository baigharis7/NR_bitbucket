import 'package:nutrenaissance_flutter/domain/interactor/recipes/delete_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

class DeleteRecipeFavoriteInteractorImpl extends DeleteRecipeFavoriteInteractor {
  final RecipesRepository recipesRepository;

  DeleteRecipeFavoriteInteractorImpl({required this.recipesRepository});

  @override
  Future<void> execute(String userId, int eventDate) => recipesRepository.deleteRecipeFavorite(userId, eventDate);

}