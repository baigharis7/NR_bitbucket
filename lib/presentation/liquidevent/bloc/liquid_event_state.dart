import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/foodevents/food_event_complete.dart';

class LiquidEventState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? liquidNames;
  List<LiquidInEvent>? liquidsInEvent;
  int? eventDate;
  bool? isEdit;
  List<FoodEventComplete>? weeklyFrequentLiquids;
  List<FoodEventComplete>? weeklyLiquids;
  FoodEventComplete? frequentLiquidAdded;

  LiquidEventState({
    required this.isLoading,
    this.onError,
    this.liquidNames,
    this.liquidsInEvent,
    this.eventDate,
    this.isEdit,
    this.weeklyFrequentLiquids,
    this.weeklyLiquids,
    this.frequentLiquidAdded,
  });

  LiquidEventState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? liquidNames,
    List<LiquidInEvent>? liquidsInEvent,
    int? eventDate,
    bool? isEdit,
    List<FoodEventComplete>? weeklyFrequentLiquids,
    List<FoodEventComplete>? weeklyLiquids,
    FoodEventComplete? frequentLiquidAdded,
  }) {
    return LiquidEventState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      liquidNames: liquidNames ?? this.liquidNames,
      liquidsInEvent: liquidsInEvent ?? this.liquidsInEvent,
      eventDate: eventDate ?? this.eventDate,
      isEdit: isEdit ?? this.isEdit,
      weeklyFrequentLiquids: weeklyFrequentLiquids ?? this.weeklyFrequentLiquids,
      weeklyLiquids: weeklyLiquids ?? this.weeklyLiquids,
      frequentLiquidAdded: frequentLiquidAdded ?? this.frequentLiquidAdded,
    );
  }

}