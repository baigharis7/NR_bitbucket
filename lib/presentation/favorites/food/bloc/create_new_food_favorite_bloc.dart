import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_state.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../../domain/models/favorites/food/meal_time.dart';
import '../../../../domain/models/foodevents/food_event_complete.dart';
import '../../../../infrastructure/mappers/favorites_mapper.dart';

class CreateNewFoodFavoriteBloc extends BaseBloc<CreateNewFoodFavoriteActions, CreateNewFoodFavoriteState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;

  CreateNewFoodFavoriteBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodFavoriteInteractor,
    required this.getWeekFoodEventsInteractor,
  }) : super(CreateNewFoodFavoriteState(isLoading: false)) {
    on<InitializeStateAction>((event, emit) async {
      _clearData();
      emit(state.copyWith(isLoading: true));
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.foodsInFavorite = [];
      // var weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      // addFrequentFromWeek(weeklyFoodEvents.orEmpty(), state.frequentFoodEvents.orEmpty());
      state.frequentFoodEvents = addFrequentFromWeek(await getWeekFoodEventsInteractor.execute());

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<RemoveFoodFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      state.foodsInFavorite!.remove(event.foodInFavorite);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddFoodFromFavoriteAction>((event, emit){
      emit(state.copyWith(isLoading: true));
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite!.remove(state.foodsInFavorite![itemIndex]);
        state.foodsInFavorite!.add(event.foodInFavorite);
      } else {
        state.foodsInFavorite!.add(event.foodInFavorite);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateQuantityAction>((event, emit) {
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].qty = event.foodInFavorite.qty;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateUnitAction>((event, emit) {
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].unit = event.foodInFavorite.unit;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateCookingMethodAction>((event, emit){
      if (state.foodsInFavorite!.map((food) => food.id).contains((event.foodInFavorite).id)) {
        final itemIndex = state.foodsInFavorite!.indexOf(state.foodsInFavorite!.firstWhere((food) => food.id == event.foodInFavorite.id));
        state.foodsInFavorite![itemIndex].cookingMethod = event.foodInFavorite.cookingMethod;
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddFoodNameAction>((event, emit){
      state.favoriteName = event.name;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddMealTimeAction>((event, emit){
      state.mealTime = event.mealTime;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishFoodFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.foodsInFavorite!,
        drinks: [],
        mealTime: state.mealTime!,
        dish: (state.foodsInFavorite.orEmpty().length > 1) ? true : false,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, false);
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

    on<AddFavFoodFromFrequent>((event, emit) {
      state.favoriteName = event.frequentFood.title;
      state.comment = event.frequentFood.comment;
      state.foodsFromFrequent = event.frequentFood.ingredients;

      emit(state.copyWith(isLoading: false));
    },);

    on<FinishFrequentFoodToAddFavorite>((event, emit) async {
      emit(state.copyWith(isLoading: true,));

      final foodFavorite = FoodFavorite(
        title: state.favoriteName.orEmpty(),
        eventDate: DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        ingredients: state.foodsFromFrequent.orEmpty(),
        drinks: [],
        mealTime: state.mealTime ?? -1,
        dish: (state.foodsFromFrequent.orEmpty().length > 1) ? true : false,
        comment: state.comment,
      );

      try {
        final uploadFavorite = await uploadFoodFavoriteInteractor.execute(foodFavorite);
        if (uploadFavorite) {
          try {
            await saveFoodFavoriteInteractor.execute(foodFavorite, false);
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

  _clearData() {
    state.foodsInFavorite?.clear();
    state.foodsFromFrequent?.clear();
    state.mealTime = null;
    state.onError = null;
    state.favoriteName = '';
    state.comment = '';
  }

  bool isFoodFavValidateList() {
    if (state.foodsInFavorite.orEmpty().isNotEmpty) {
      return state.foodsInFavorite.orEmpty().any((foodFav) { return foodFav.qty <= 0; },);
    } else {
      return true;
    }
  }

  List<FoodFavorite> addFrequentFromWeek(List<FoodEventComplete> foodList,) {
    List<FoodFavorite> favoriteList = [];
    for (int i = 0; i < foodList.length; i++) {
      int count = 1;
      for (int j = i + 1; j < foodList.length; j++) {
        FoodEventComplete selectedItem = foodList[i];
        FoodEventComplete matchableItem = foodList[j];
        if (areFoodInfoListsEqual(selectedItem.foodInfo!, matchableItem.foodInfo!)) {
          count = count + 1;
        }
      }
      if (count == 3) {
        favoriteList.add(mapToFoodFavoriteFromFoodEvent(foodList[i]));
      }
    }
    return favoriteList;
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
    return (obj1.id == obj2.id && obj1.eventInfo!.qty == obj2.eventInfo!.qty && obj1.eventInfo!.unit == obj2.eventInfo!.unit && obj1.eventInfo!.cookingMethod == obj2.eventInfo!.cookingMethod);
  }

  List<FoodFavorite> getFoodListByType(MealTime mealTime) {
    final list = <FoodFavorite>[];
    for (var favorite in state.frequentFoodEvents.orEmpty()) {
      if (favorite.mealTime == mealTime.id) {
        list.add(favorite);
      }
    }
    return list;
  }
}