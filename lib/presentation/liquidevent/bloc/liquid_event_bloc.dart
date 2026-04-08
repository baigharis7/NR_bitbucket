import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_state.dart';

import '../../../domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import '../../../infrastructure/mappers/liquid_event_mappers.dart';

class LiquidEventBloc extends BaseBloc<LiquidEventActions, LiquidEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadLiquidEventInteractor uploadLiquidEventInteractor;
  final SaveLiquidEventInteractor saveLiquidEventInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;

  LiquidEventBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.uploadLiquidEventInteractor,
    required this.saveLiquidEventInteractor,
    required this.getWeekLiquidEventsInteractor,
  }) : super(LiquidEventState(
    isLoading: false,
    liquidNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(
      foodNames: [],
      drinkNames: [],
    ),),
    liquidsInEvent: [],
    weeklyFrequentLiquids: [],
    eventDate: null,
    isEdit: false,
  ),) {

    on<InitializeStateAction>((event, emit) async {
      _clearFields();
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate),);
      if (state.liquidNames!.foodsAndDrinksNames!.drinkNames!.isEmpty) {
        final names = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
        state.liquidNames = names;
      }
      state.weeklyLiquids = await getWeekLiquidEventsInteractor.execute();
      if (state.weeklyLiquids.orEmpty().isNotEmpty) {
        addFrequentFromWeek(state.weeklyLiquids.orEmpty(), state.weeklyFrequentLiquids.orEmpty());
      }

      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<ReceiveEventDateAction>((event, emit) {
      state.eventDate = event.dateTime.millisecondsSinceEpoch;
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    });

    on<AddLiquidFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      if (state.liquidsInEvent!.map((food) => food.id).contains((event.liquid).id)) {
        final itemIndex = state.liquidsInEvent!.indexOf(state.liquidsInEvent!.firstWhere((food) => food.id == event.liquid.id));
        state.liquidsInEvent!.remove(state.liquidsInEvent![itemIndex]);
        state.liquidsInEvent!.add(event.liquid);
      } else {
        state.liquidsInEvent!.add(event.liquid);
      }
      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<RemoveLiquidFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      state.liquidsInEvent!.remove(event.liquid);

      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<FinishLiquidEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));

      final liquidEvent = LiquidEventSimple(
        userId: getUserIdInteractor.execute(),
        date: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
      );
      liquidEvent.drinks = state.liquidsInEvent.orEmpty();

      try {
        final uploadLiquidEvent = await uploadLiquidEventInteractor.execute(liquidEvent);
        if (uploadLiquidEvent.uploadSuccess) {
          await saveLiquidEventInteractor.execute(uploadLiquidEvent, state.isEdit!);
          DashboardEventBus.instance.notify(DataChangedCategory.liquid);
          _clearFields();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
        } else {
          state.onError = ErrorTypes.uploadLiquidEventError;
          emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
        }
      } catch (error) {
        state.onError = ErrorTypes.uploadLiquidEventError;
        emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
      }
    });

    on<ReceiveLiquidsInEventFromNavigationAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      state.isEdit = true;
      state.eventDate = event.liquidEventSimple.date;
      state.liquidsInEvent = event.liquidEventSimple.drinks;
      if (state.liquidNames!.foodsAndDrinksNames!.drinkNames!.isEmpty) {
        final names = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
        state.liquidNames = names;
      }

      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    });

    on<ResetLiquidEventInfoAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null, eventDate: null, liquidsInEvent: [], isEdit: false,));
    });

    on<AddLiquidFrequentEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true,));
      state.frequentLiquidAdded = event.liquidFrequent;

      emit(state.copyWith(isLoading: false,));
    },);

    on<FinishFrequentLiquidEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final liquidEvent = LiquidEventSimple(
        userId: getUserIdInteractor.execute(),
        date: DateTime.now().millisecondsSinceEpoch,
      );
      liquidEvent.drinks = mapToLiquidInEventList(state.frequentLiquidAdded?.foodInfo ?? []);

      try {
        final uploadLiquidEvent = await uploadLiquidEventInteractor.execute(liquidEvent);
        if (uploadLiquidEvent.uploadSuccess) {
          await saveLiquidEventInteractor.execute(uploadLiquidEvent, state.isEdit!);
          DashboardEventBus.instance.notify(DataChangedCategory.liquid);
          _clearFields();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
        } else {
          state.onError = ErrorTypes.uploadLiquidEventError;
          emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
        }
      } catch (error) {
        state.onError = ErrorTypes.uploadLiquidEventError;
        emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
      }
    },);
  }

  void _clearFields() {
    state.liquidsInEvent?.clear();
    // state.drinkName = '';
    // state.comment = null;
    state.eventDate = null;
    state.onError = null;
    state.frequentLiquidAdded = null;
    state.liquidNames = FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(drinkNames: [], foodNames: []));
    state.weeklyFrequentLiquids = [];
    state.isEdit = false;
  }

  LiquidInEvent? findLiquidId(String drinkName, String currentLanguage) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = state.liquidNames!.foodsAndDrinksNames!.drinkNames?.firstWhere((food) => food.es == drinkName);
    } else {
      foodItem = state.liquidNames!.foodsAndDrinksNames!.drinkNames?.firstWhere((food) => food.en == drinkName);
    }
    if (foodItem != null) {
      return LiquidInEvent(id: foodItem.id!, qty: 0,);
    } else {
      return null;
    }
  }

  String findLiquidNameFromId(int foodId, BuildContext context) {
    return state.liquidNames!.foodsAndDrinksNames!.drinkNames!.firstWhere((foodItemMaster) => foodId == foodItemMaster.id).translate(context);
  }

  void addFrequentFromWeek(List<FoodEventComplete> weeklyLiquids, List<FoodEventComplete> weeklyFrequentLiquids) {
    for (int i = 0; i < weeklyLiquids.length; i++) {
      int count = 1;
      for (int j = i + 1; j < weeklyLiquids.length; j++) {
        FoodEventComplete selectedItem = weeklyLiquids[i];
        FoodEventComplete matchableItem = weeklyLiquids[j];
        if (areFoodInfoListsEqual(selectedItem.foodInfo!, matchableItem.foodInfo!)) {
          count = count + 1;
        }
      }
      if (count == 3) {
        weeklyFrequentLiquids.add(weeklyLiquids[i]);
      }
    }
  }

  bool areFoodInfoListsEqual(List<FoodInfo> list1, List<FoodInfo> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (!areFoodInfoObjectsEqual(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }
  bool areFoodInfoObjectsEqual(FoodInfo obj1, FoodInfo obj2) {
    return (obj1.id == obj2.id && obj1.eventInfo!.qty == obj2.eventInfo!.qty && obj1.eventInfo!.unit == obj2.eventInfo!.unit);
  }

}