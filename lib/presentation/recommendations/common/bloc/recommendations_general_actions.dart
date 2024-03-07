import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';

class RecommendationsGeneralActions {
  RecommendationsGeneralActions();
}

class InitialStateAction extends RecommendationsGeneralActions {
  InitialStateAction();
}

class EmptyRecommendationAction extends RecommendationsGeneralActions {
  EmptyRecommendationAction();
}

class ManageFoodToListAction extends RecommendationsGeneralActions {
  final SimpleItem foodItem;

  ManageFoodToListAction({required this.foodItem});
}

class HideRecommendationsExplainingCardAction extends RecommendationsGeneralActions {
  HideRecommendationsExplainingCardAction();
}

class SetFoodIdsAndGetRecipesAction extends RecommendationsGeneralActions {
  SetFoodIdsAndGetRecipesAction();
}

class FilterRecipesListByIngredientAction extends RecommendationsGeneralActions {
  final String foodName;
  final String currentLanguage;

  FilterRecipesListByIngredientAction({required this.foodName, required this.currentLanguage});
}

class RestoreRecipesListAction extends RecommendationsGeneralActions {
  RestoreRecipesListAction();
}

class HideFoodListExplainingCardAction extends RecommendationsGeneralActions {
  HideFoodListExplainingCardAction();
}

class OnDeleteFoodIdFromList extends RecommendationsGeneralActions {
  final SimpleItem foodItem;

  OnDeleteFoodIdFromList({required this.foodItem});
}

class HideRecipeExplainingCardAction extends RecommendationsGeneralActions {
  HideRecipeExplainingCardAction();
}

class UpdateProfileAction extends RecommendationsGeneralActions {

}