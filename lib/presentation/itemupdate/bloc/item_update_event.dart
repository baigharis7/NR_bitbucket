part of 'item_update_bloc.dart';

@immutable
abstract class ItemUpdateEvent {}

class InitializeItemUpdateEvent extends ItemUpdateEvent {}

class UpdateFoodFromLoggedItemUpdateEvent extends ItemUpdateEvent {
  final FoodEventComplete foodEventComplete;

  UpdateFoodFromLoggedItemUpdateEvent({required this.foodEventComplete});
}

class UpdateEventDateItemUpdateEvent extends ItemUpdateEvent {
  final DateTime dateTime;

  UpdateEventDateItemUpdateEvent({required this.dateTime});
}

class AddFoodItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;

  AddFoodItemUpdateEvent({required this.foodInEvent});
}

class RemoveFoodItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;
  final Function isGoBack;

  RemoveFoodItemUpdateEvent({required this.foodInEvent, required this.isGoBack});
}

class UpdateQuantityItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;

  UpdateQuantityItemUpdateEvent({required this.foodInEvent});
}

class UpdateUnitItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;

  UpdateUnitItemUpdateEvent({required this.foodInEvent});
}

class UpdateConversionFactorItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;

  UpdateConversionFactorItemUpdateEvent({required this.foodInEvent});
}

class UpdateCookingMethodItemUpdateEvent extends ItemUpdateEvent {
  final FoodInFavorite foodInEvent;

  UpdateCookingMethodItemUpdateEvent({required this.foodInEvent});
}

class UpdateOilItemUpdateEvent extends ItemUpdateEvent {
  FoodInFavorite foodInEvent;

  UpdateOilItemUpdateEvent({required this.foodInEvent});
}

class FinishUpdateFoodEventAction extends ItemUpdateEvent {
  final Function onFinish;

  FinishUpdateFoodEventAction({required this.onFinish});
}
