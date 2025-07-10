import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_state.dart';

import '../../../../domain/interactor/preferences/get_user_id_interactor.dart';
import '../../../../domain/models/foodevents/food_event_complete.dart';
import '../../../../domain/models/foodevents/food_event_simple.dart';

class AddFavoriteFoodBloc extends BaseBloc<AddFavoriteFoodActions, AddFavoriteFoodState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor;

  AddFavoriteFoodBloc({
    required this.getMasterFileInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodFavoriteInteractor,
    required this.uploadFoodEventInteractor,
    required this.saveFoodEventInteractor,
    required this.getUserIdInteractor,
    required this.getFoodFavoritesInteractor,
    required this.deleteFoodFavoriteInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
  }) : super(AddFavoriteFoodState(
    isLoading: false,
    onError: null,
    foodsInFavorite: [],
    foodNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])),
    cookingMethodsMaster: CookingMethodsMaster(cookingMethods: []),
    cookingMethodsInfoMaster: CookingMethodsInfoMaster(cookingMethodsInfo: []),
    unitsInfoMaster: UnitsInfoMaster(unitsInfoMaster: []),
    unitsFoodsMaster: UnitsFoodsMaster(unitsFoodsMaster: []),
    favoriteName: '',
    isEdit: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.oilTypes = await getMasterFileInteractor.execute(MasterFilesType.oilTypes);
      state.conversionFactors = await getMasterFileInteractor.execute(MasterFilesType.conversionFactors);
      state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.favoriteFoods = await getFoodFavoritesInteractor.execute();
      
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetFoodsInFavoriteAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null));

      state.foodsInFavorite = mapToFoodFavoriteList(event.foodsInFavorite.foodInfo!);
      state.comment = event.foodsInFavorite.comment;
      state.mealTime = event.foodsInFavorite.mealType;
      state.favoriteName = event.foodsInFavorite.foodName;
      state.dish = event.foodsInFavorite.dish;
      emit(state.copyWith(isLoading: false,));
    });

    on<AddCommentToFavoriteActions>((event, emit) {
      state.comment = event.comment;

      emit(state.copyWith(isLoading: false));
    });

    on<AddFoodNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetFoodFavoriteToEditAction>((event, emit) {
      emit(state.copyWith(isLoading: true));

      state.favoriteName = event.foodFavorite.title;
      state.mealTime = event.foodFavorite.mealTime;
      state.comment = event.foodFavorite.comment;
      state.dish = event.foodFavorite.dish;
      state.foodsInFavorite = event.foodFavorite.ingredients;
      state.isEdit = true;
      state.eventDate = event.foodFavorite.eventDate;

      emit(state.copyWith(isLoading: false));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: state.eventDate ?? DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.foodsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
        comment: state.comment,
        dish: state.dish,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, state.isEdit!);
            _clearData();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
      }
    });

    on<FinishFoodCommentAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, eventDate: state.eventDate));

      final foodEvent = FoodEventSimple(
          userId: getUserIdInteractor.execute(),
          eventDate: event.foodEventComplete.eventDate ?? DateTime.now().millisecondsSinceEpoch,
          eventId: event.foodEventComplete.eventDate ?? DateTime.now().millisecondsSinceEpoch,
          foodName: event.foodEventComplete.foodName ?? '',
          comment: state.comment,
        dish: state.dish,
      );
      state.isEdit = true;
      foodEvent.ingredients = state.foodsInFavorite?.map((food) => FoodInEvent(id: food.id, qty: food.qty, unit: food.unit, cookingMethod: food.cookingMethod)).toList();
      foodEvent.drinks = []; // TODO: is it necessary to implement drinks in food events?

      try {
        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEvent);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);
            _clearData();
            emit(state.copyWith(isLoading: false, onError: null, eventDate: null));
            event.onFinish.call();
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

    on<RemoveFavoriteFoodEventAction>((event, emit) async {
      if(event.foodFavorite.isNull()) return;
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodFavoriteInteractor.execute(getUserIdInteractor.execute(), event.foodFavorite!.eventDate.orZero());
        try {
          await removeFoodFavoriteFromLocalInteractor.execute(event.foodFavorite!);
          _clearData();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    });

    on<FinishFoodFavoriteCommentAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: event.foodFavorite.title.orEmpty(),
        eventDate: event.foodFavorite.eventDate ?? DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: event.foodFavorite.ingredients,
        drinks: [],
        mealTime: event.foodFavorite.mealTime,
        comment: state.comment,
        dish: state.dish,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, true);
            _clearData();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
      }
    },);
  }

  bool isFoodFavourite(FoodEventComplete foodEvent) {
    var isFavourite = false;
    parentLoop:for (FoodFavorite favFood in state.favoriteFoods ?? []) {

      if (favFood.ingredients.length == (foodEvent.foodInfo?.length ?? 0)) {
        childLoop:for (FoodInfo foodInfoItem in foodEvent.foodInfo!) {
          isFavourite = favFood.ingredients.any((ingredientItem) => ingredientItem.id == foodInfoItem.id && ingredientItem.cookingMethod == foodInfoItem.eventInfo!.cookingMethod && ingredientItem.qty == foodInfoItem.eventInfo!.qty);
          if (!isFavourite) break childLoop;
        }
      }
    }

    return isFavourite;
  }

  void _clearData() {
    state.comment = null;
    state.dish = null;
    state.favoriteName = null;
    state.mealTime = null;
    state.isEdit = false;
    state.eventDate = null;
    state.foodsInFavorite?.clear();
  }

  FoodFavorite? isFoundObjectFromFavoriteList(FoodFavorite foodFavoriteFromEvent) {
    FoodFavorite? object;
    bool isFound = false;
    parentLoop: for (FoodFavorite favObject in state.favoriteFoods.orEmpty()) {
      object = favObject;
      if (favObject.ingredients.length == foodFavoriteFromEvent.ingredients.length) {
        childLoop: for (FoodInFavorite matchingObject in foodFavoriteFromEvent.ingredients) {
          isFound = favObject.ingredients.any((ingredientItem) => ingredientItem.id == matchingObject.id && ingredientItem.cookingMethod == matchingObject.cookingMethod && ingredientItem.qty == matchingObject.qty);
          if (!isFound) break childLoop;
        }
      }
    }
    return isFound ? object : null;
  }

}