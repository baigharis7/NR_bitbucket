part of 'food_bloc.dart';

@immutable
abstract class FoodEventActions {}

class InitializeStateEventAction extends FoodEventActions {
  InitializeStateEventAction();
}

class OnChangeEditTextStateAction extends FoodEventActions {
  final String foodName;
  OnChangeEditTextStateAction(this.foodName);
}
