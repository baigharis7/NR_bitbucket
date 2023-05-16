import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

class AddFavoriteLiquidActions {
  AddFavoriteLiquidActions();
}

class InitializeStateAction extends AddFavoriteLiquidActions {
  InitializeStateAction();
}

class SetLiquidsInFavoriteAction extends AddFavoriteLiquidActions {
  final List<LiquidInFavorite> liquidsInFavorite;

  SetLiquidsInFavoriteAction({required this.liquidsInFavorite});
}

class AddCommentToFavoriteActions extends AddFavoriteLiquidActions {
  final String comment;
  final Function onFinish;

  AddCommentToFavoriteActions({required this.comment, required this.onFinish});
}

class AddLiquidNameAction extends AddFavoriteLiquidActions {
  String name;

  AddLiquidNameAction({required this.name});
}

class AddMealTimeAction extends AddFavoriteLiquidActions {
  int mealTime;

  AddMealTimeAction({required this.mealTime});
}


class FinishAddingFavoriteAction extends AddFavoriteLiquidActions {
  final Function onFinish;

  FinishAddingFavoriteAction({required this.onFinish});
}