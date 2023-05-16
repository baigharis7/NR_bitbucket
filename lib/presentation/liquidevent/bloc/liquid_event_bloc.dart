import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/save_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/upload_liquid_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/bloc/liquid_event_state.dart';

class LiquidEventBloc extends BaseBloc<LiquidEventActions, LiquidEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadLiquidEventInteractor uploadLiquidEventInteractor;
  final SaveLiquidEventInteractor saveLiquidEventInteractor;

  LiquidEventBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.uploadLiquidEventInteractor,
    required this.saveLiquidEventInteractor,
  }) : super(LiquidEventState(
    isLoading: false,
    liquidNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(
      foodNames: [],
      drinkNames: [],
    ),),
    liquidsInEvent: [],
    eventDate: null,
    isEdit: false,
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate),);
      if (state.liquidNames!.foodsAndDrinksNames!.drinkNames!.isEmpty) {
        final names = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
        state.liquidNames = names;
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
          try {
            await saveLiquidEventInteractor.execute(uploadLiquidEvent, state.isEdit!);
            state.liquidsInEvent!.clear();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
          } catch (error) {
            state.onError = ErrorTypes.locallySavingFoodEventError;
            emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
          }
        } else {
          state.onError = ErrorTypes.uploadingFoodEventError;
          emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
        }
      } catch (error) {
        state.onError = ErrorTypes.uploadingFoodEventError;
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

}