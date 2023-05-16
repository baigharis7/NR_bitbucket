class RecipesActions {
  RecipesActions();
}

class InitializeStateAction extends RecipesActions {
  InitializeStateAction();
}

class SetFoodIdsAndGetRecipesAction extends RecipesActions {
  List<int> foodIds;

  SetFoodIdsAndGetRecipesAction({required this.foodIds});
}

class FilterRecipesListByIngredientAction extends RecipesActions {
  final String foodName;
  final String currentLanguage;

  FilterRecipesListByIngredientAction({required this.foodName, required this.currentLanguage});
}

class RestoreRecipesListAction extends RecipesActions {
  RestoreRecipesListAction();
}

class HideExplainingCardAction extends RecipesActions {
  HideExplainingCardAction();
}

class EmptyRecommendationAction extends RecipesActions {
  EmptyRecommendationAction();
}