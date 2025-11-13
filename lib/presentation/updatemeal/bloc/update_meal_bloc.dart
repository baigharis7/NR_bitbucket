import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

import '../../../data/api/masterfiles/model/conversion_factors_response.dart';
import '../../../data/api/masterfiles/model/oil_types_response.dart';
import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/masterfiles/cooking_methods_info_master.dart';
import '../../../domain/models/masterfiles/cooking_methods_master.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/units_foods_master.dart';
import '../../../domain/models/masterfiles/units_info_master.dart';

part 'update_meal_event.dart';
part 'update_meal_state.dart';

class UpdateMealBloc extends Bloc<UpdateMealEvent, UpdateMealState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodRoutineInteractor uploadFoodRoutineInteractor;
  final SaveFoodRoutineInteractor saveFoodRoutineInteractor;

  UpdateMealBloc({
    required this.getMasterFileInteractor,
    required this.uploadFoodFavoriteInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodRoutineInteractor,
    required this.saveFoodRoutineInteractor,
}) : super(UpdateMealState(isLoading: false)) {
    on<InitializationUpdateMealEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);
      final oils = await getMasterFileInteractor.execute(MasterFilesType.oilTypes);
      state.oilTypes = oils;
      state.conversionFactors = await getMasterFileInteractor.execute(MasterFilesType.conversionFactors);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      final unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsFoodsMaster = unitsFoodsMaster;
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<MealFromArgumentUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.foodEvent = event.foodFavorite;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateNameUpdateMealEvent>((event, emit) {
      state.foodEvent?.title = event.name;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateMealTimeUpdateMealEvent>((event, emit) {
      state.foodEvent?.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateIngredientsUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
        state.foodEvent!.ingredients.add(event.ingredient);
      } else {
        state.foodEvent!.ingredients.insert(0, event.ingredient);
      }
      emit(state.copyWith(isLoading: false,));
    });

    on<RemoveIngredientUpdateMealEvent>((event, emit) {
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
      }

      if (state.foodEvent?.ingredients.isEmpty == true) event.isGoBack.call();

      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateIngredientAmountUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients[itemIndex].qty = event.ingredient.qty;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateIngredientUnitUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients[itemIndex].unit = event.ingredient.unit;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateIngredientPreparationUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients[itemIndex].conversionFactor = event.ingredient.conversionFactor;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateIngredientCookingMethodUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients[itemIndex].cookingMethod = event.ingredient.cookingMethod;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateIngredientOilUpdateMealEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.ingredient).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.ingredient.id));
        state.foodEvent!.ingredients[itemIndex].usedOil = event.ingredient.usedOil;
      }

      emit(state.copyWith(isLoading: false,));
    });

    on<SaveUpdateMealUpdateMealEvent>((event, emit) {
      if (state.foodEvent?.isRoutine == true) {
        if (state.foodEvent?.daysOfWeek?.isEmpty == true) return;
        add(SaveUpdateMealRoutineUpdateMealEvent(onFinish: event.onFinish));
      } else {
        add(SaveUpdateMealFavoriteUpdateMealEvent(onFinish: event.onFinish));
      }

    });

    on<SaveUpdateMealFavoriteUpdateMealEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      try {
        final uploadFoodAsFavorite = await uploadFoodFavoriteInteractor.execute(state.foodEvent!);
        try {
          final saveFoodsAsFavorite = await saveFoodFavoriteInteractor.execute(state.foodEvent!, true);
          event.onFinish.call();
          _clearFields();
          emit(state.copyWith(isLoading: false, onError: null,));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodFavoriteError));
      }
    });

    on<SaveUpdateMealRoutineUpdateMealEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        final foodRoutine = mapToFoodRoutineEventFromFoodFavorite(state.foodEvent!);
        final uploadedRoutine = await uploadFoodRoutineInteractor.execute(foodRoutine);
        if (uploadedRoutine) {
          try {
            await saveFoodRoutineInteractor.execute(foodRoutine, true);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null,));
          } catch (_) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodRoutineEventError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodRoutineEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodRoutineEventError));
      }
    });
  }
  void _clearFields() {
    state.foodEvent = FoodFavorite.empty();
  }
}
