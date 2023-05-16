import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

class CreateNewLiquidFavoriteActions {
  CreateNewLiquidFavoriteActions();
}

class InitializeStateAction extends CreateNewLiquidFavoriteActions {
  InitializeStateAction();
}

class RemoveLiquidFromFavoriteAction extends CreateNewLiquidFavoriteActions {
  LiquidInFavorite liquidInFavorite;

  RemoveLiquidFromFavoriteAction({required this.liquidInFavorite});
}

class AddLiquidFromFavoriteAction extends CreateNewLiquidFavoriteActions {
  LiquidInFavorite liquidInFavorite;

  AddLiquidFromFavoriteAction({required this.liquidInFavorite});
}

class SelectCookingMethodAction extends CreateNewLiquidFavoriteActions {
  LiquidInFavorite liquidInFavorite;

  SelectCookingMethodAction({required this.liquidInFavorite});
}

class AddLiquidNameAction extends CreateNewLiquidFavoriteActions {
  String name;

  AddLiquidNameAction({required this.name});
}

class AddMealTimeAction extends CreateNewLiquidFavoriteActions {
  int mealTime;

  AddMealTimeAction({required this.mealTime});
}

class FinishLiquidFavoriteAction extends CreateNewLiquidFavoriteActions {
  Function onFinish;

  FinishLiquidFavoriteAction({required this.onFinish});
}