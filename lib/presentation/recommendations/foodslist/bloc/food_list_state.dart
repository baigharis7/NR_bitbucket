import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class FoodListState {
  bool isLoading;
  ErrorTypes? onError;
  List<int>? foodIdsList;
  List<SimpleItem>? foodNamesList;
  FoodsAndDrinksNamesMaster? foodNames;
  bool? showCard;

  FoodListState({
    required this.isLoading,
    this.onError,
    this.foodIdsList,
    this.foodNamesList,
    this.foodNames,
    this.showCard,
  });

  FoodListState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<int>? foodIdsList,
    List<SimpleItem>? foodNamesList,
    FoodsAndDrinksNamesMaster? foodNames,
    bool? showCard,
  }) {
    return FoodListState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodIdsList: foodIdsList ?? this.foodIdsList,
      foodNamesList: foodNamesList ?? this.foodNamesList,
      foodNames: foodNames ?? this.foodNames,
      showCard: showCard ?? this.showCard,
    );
  }
}