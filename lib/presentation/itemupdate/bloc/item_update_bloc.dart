import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

import '../../../data/api/masterfiles/model/conversion_factors_response.dart';
import '../../../data/api/masterfiles/model/oil_types_response.dart';
import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/save_food_event_interactor.dart';
import '../../../domain/interactor/foodevents/upload_food_event_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/masterfiles/cooking_methods_info_master.dart';
import '../../../domain/models/masterfiles/cooking_methods_master.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/units_foods_master.dart';
import '../../../domain/models/masterfiles/units_info_master.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'item_update_event.dart';
part 'item_update_state.dart';

class ItemUpdateBloc extends Bloc<ItemUpdateEvent, ItemUpdateState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;

  ItemUpdateBloc({
    required this.getMasterFileInteractor,
    required this.uploadFoodEventInteractor,
    required this.saveFoodEventInteractor,
  }) : super(ItemUpdateState(isLoading: false)) {
    on<InitializeItemUpdateEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true,  onError: null));
        final foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
        state.foodNames = foodNames;
        state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);
      state.oilTypes = await getMasterFileInteractor.execute(MasterFilesType.oilTypes);
      state.conversionFactors = await getMasterFileInteractor.execute(MasterFilesType.conversionFactors);
        final a = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
        state.cookingMethodsInfoMaster = a;
        state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
        state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
        state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateEventDateItemUpdateEvent>((event, emit) {
      state.foodEvent?.eventDate = event.dateTime.millisecondsSinceEpoch;

      emit(state.copyWith(isLoading: false));
    });

    on<AddFoodItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
        state.foodEvent!.ingredients.add(event.foodInEvent);
      } else {
        state.foodEvent!.ingredients.insert(0, event.foodInEvent);
        // state.foodsInEvent!.add(event.foodInEvent);
      }
      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateFoodFromLoggedItemUpdateEvent>((event, emit) {
      state.foodEvent = mapToFoodFavoriteFromFoodEvent(event.foodEventComplete);
      emit(state.copyWith(isLoading: false));
    });

    on<RemoveFoodItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));

      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
      }

      if (state.foodEvent?.ingredients.isEmpty == true) event.isGoBack.call();

      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateQuantityItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].qty = event.foodInEvent.qty;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateUnitItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].unit = event.foodInEvent.unit;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateConversionFactorItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].conversionFactor = event.foodInEvent.conversionFactor;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateCookingMethodItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].cookingMethod = event.foodInEvent.cookingMethod;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateOilItemUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].usedOil = event.foodInEvent.usedOil;
      }

      emit(state.copyWith(isLoading: false,));
    });

    on<FinishUpdateFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        final foodEventSimple = mapToFoodEventSimpleFromFoodFavorite(state.foodEvent!);

        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEventSimple);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, true);

            _clearFields();
            emit(state.copyWith(isLoading: false,));
            event.onFinish.call();
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.locallySavingFoodEventError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodEventError));
      }
    });
  }

  void _clearFields() {
    state.foodEvent = FoodFavorite.empty();
  }

  bool? validateList() {
    return state.foodEvent?.ingredients.any((food) {
      return food.qty <= 0 || food.unit == -1;
    },);
  }
}
