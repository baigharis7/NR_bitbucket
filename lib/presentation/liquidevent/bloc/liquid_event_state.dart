import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class LiquidEventState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? liquidNames;
  List<LiquidInEvent>? liquidsInEvent;
  int? eventDate;
  bool? isEdit;

  LiquidEventState({
    required this.isLoading,
    this.onError,
    this.liquidNames,
    this.liquidsInEvent,
    this.eventDate,
    this.isEdit,
  });

  LiquidEventState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? liquidNames,
    List<LiquidInEvent>? liquidsInEvent,
    required int? eventDate,
    bool? isEdit,
  }) {
    return LiquidEventState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      liquidNames: liquidNames ?? this.liquidNames,
      liquidsInEvent: liquidsInEvent ?? this.liquidsInEvent,
      eventDate: eventDate,
      isEdit: isEdit ?? this.isEdit,
    );
  }

}