import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';

class AddFoodEventBloc extends BaseBloc<AddFoodEventActions, AddFoodEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;

  AddFoodEventBloc({
    required this.getUserIdInteractor,
    required this.saveFoodEventInteractor,
    required this.uploadFoodEventInteractor,
    required this.getMasterFileInteractor,
    required this.getFoodFavoritesInteractor,
    required this.getWeekFoodEventsInteractor,
  }) : super(AddFoodEventState(
    isLoading: false,
    foodNames: FoodsAndDrinksNamesMaster(
      FoodsAndDrinkListsMaster(
        foodNames: [],
        drinkNames: [],
      ),
    ),
    foodsInEvent: [],
    cookingMethodsInfoMaster: CookingMethodsInfoMaster(cookingMethodsInfo: []),
    cookingMethodsMaster: CookingMethodsMaster(cookingMethods: []),
    unitsFoodsMaster: UnitsFoodsMaster(unitsFoodsMaster: []),
    unitsInfoMaster: UnitsInfoMaster(unitsInfoMaster: []),
    foodName: '',
    eventDate: null,
    isEdit: false,
    foodFavorites: [],
    foodsFromFavorite: [],
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      if (state.foodNames!.foodsAndDrinksNames!.foodNames!.isEmpty) {
        state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      }
      if (state.cookingMethodsInfoMaster!.cookingMethodsInfo!.isEmpty) {
        state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      }
      if (state.cookingMethodsMaster!.cookingMethods.isEmpty) {
        state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      }
      if (state.unitsFoodsMaster!.unitsFoodsMaster.isEmpty) {
        state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      }
      if (state.unitsInfoMaster!.unitsInfoMaster.isEmpty) {
        state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      }
      state.foodFavorites = await getFoodFavoritesInteractor.execute();
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      if (state.weeklyFoodEvents.orEmpty().isNotEmpty && state.foodFavorites.orEmpty().isNotEmpty) {
        addFrequentFromWeek(state.weeklyFoodEvents!, state.foodFavorites!);
      }

      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    },);

    on<RemoveFoodFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      state.foodsInEvent!.remove(event.foodInEvent);

      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<AddFoodFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      if (state.foodsInEvent!.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodsInEvent!.indexOf(state.foodsInEvent!.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodsInEvent!.remove(state.foodsInEvent![itemIndex]);
        state.foodsInEvent!.add(event.foodInEvent);
      } else {
        state.foodsInEvent!.add(event.foodInEvent);
      }
      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<UpdateFoodQuantityEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      if (state.foodsInEvent!.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodsInEvent!.indexOf(state.foodsInEvent!.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodsInEvent![itemIndex].qty = event.foodInEvent.qty;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateFoodUnitEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      if (state.foodsInEvent!.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodsInEvent!.indexOf(state.foodsInEvent!.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodsInEvent![itemIndex].unit = event.foodInEvent.unit;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateFoodCookingMethodEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      if (state.foodsInEvent!.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodsInEvent!.indexOf(state.foodsInEvent!.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodsInEvent![itemIndex].cookingMethod = event.foodInEvent.cookingMethod;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<AddFoodNameEventAction>((event, emit) {
      state.foodName = event.foodName;
      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    },);

    // on<SelectCookingMethodAction>((event, emit) {
    //   state.foodsInEvent!.add(event.foodInEvent);
    //   emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    // });

    on<FinishFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, eventDate: state.eventDate));

      final foodEvent = FoodEventSimple(
          userId: getUserIdInteractor.execute(),
          eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        foodName: state.foodName ?? '',
        comment: state.comment
      );
      foodEvent.ingredients = state.foodsInEvent.orEmpty();
      foodEvent.drinks = []; // TODO: is it necessary to implement drinks in food events?

      try {
        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEvent);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);

            _clearFields();
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

    on<ReceiveFoodsInEventFromNavigationAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, eventDate: state.eventDate));
      state.isEdit = true;
      state.eventDate = event.foodEventSimple.eventDate;
      state.eventId = event.foodEventSimple.eventId;
      state.foodsInEvent = event.foodEventSimple.ingredients;
      if (state.foodNames!.foodsAndDrinksNames!.foodNames!.isEmpty) {
        state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      }
      if (state.cookingMethodsInfoMaster!.cookingMethodsInfo!.isEmpty) {
        state.cookingMethodsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
      }
      if (state.cookingMethodsMaster!.cookingMethods.isEmpty) {
        state.cookingMethodsMaster = await getMasterFileInteractor.execute(MasterFilesType.cookingMethods);
      }
      if (state.unitsFoodsMaster!.unitsFoodsMaster.isEmpty) {
        state.unitsFoodsMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsFoods);
      }
      if (state.unitsInfoMaster!.unitsInfoMaster.isEmpty) {
        state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      }
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    });

    on<ResetFoodEventInfoAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null, eventDate: null, foodsInEvent: [], isEdit: false,));
    });

    on<ReceiveEventDateAction>((event, emit) {
      state.eventDate = event.dateTime.millisecondsSinceEpoch;
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    });

    on<AddFoodFromFavouriteEventAction>((event, emit) {
      state.foodName = event.foodFavorite.title;
      state.comment = event.foodFavorite.comment;
      state.foodsFromFavorite = event.foodFavorite.ingredients.map((item) {
        return FoodInEvent(id: item.id, qty: item.qty, unit: item.unit, cookingMethod: item.cookingMethod);
      },).toList();
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    },);

    on<FinishFoodFavouriteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, eventDate: state.eventDate));

      final foodEvent = FoodEventSimple(
        userId: getUserIdInteractor.execute(),
        eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        foodName: state.foodName ?? '',
        comment: state.comment,
      );
      foodEvent.ingredients = state.foodsFromFavorite.orEmpty();
      foodEvent.drinks = []; // TODO: is it necessary to implement drinks in food events?

      try {
        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEvent);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);

            _clearFields();
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
    },);

    on<AddFoodEventFromDetailNavigation>((event, emit) {
      state.eventDate = event.foodEventComplete.eventDate;
      state.eventId = event.foodEventComplete.eventId;
      state.foodName = event.foodEventComplete.foodName;
      state.comment = event.foodEventComplete.comment;
      state.isEdit = true;
      state.foodsInEvent = event.foodEventComplete.foodInfo?.map((food) => FoodInEvent(id: food.id!, qty: food.eventInfo!.qty!.toInt(), unit: food.eventInfo!.unit!, cookingMethod: food.eventInfo!.cookingMethod!)).toList();
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    },);
  }

  void _clearFields() {
    state.foodsFromFavorite?.clear();
    state.foodsInEvent?.clear();
    state.foodName = '';
    state.comment = null;
    state.eventDate = null;
    state.eventId = null;
    state.isEdit = false;
  }

  UnitInfoMaster findUnitName(int unitId) {
    final unitInfo = state.unitsInfoMaster!.unitsInfoMaster
        .firstWhere((unitInfo) => unitInfo.id == unitId, orElse: () => UnitInfoMaster.empty(),);
    if (unitInfo.id == 0) {
      return UnitInfoMaster.empty();
    } else {
      return unitInfo;
    }
  }

  bool? validateList() {
     return state.foodsInEvent?.any((food) {
      return food.qty < 0;
    },);
  }

  void addFrequentFromWeek(List<FoodEventComplete> foodList, List<FoodFavorite> favoriteList) {
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
  }

  bool compareTwoList(List<FoodInfo> foodInfoA, List<FoodInfo> foodInfoB) {
    for (int index = 0; index < foodInfoA.length; index += 1) {
      if (foodInfoA[index] == foodInfoB[index]) {
        return true;
      }
    }
    return false;
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
    // return obj1.id == obj2.id;
    return (obj1.id == obj2.id && obj1.eventInfo!.qty == obj2.eventInfo!.qty && obj1.eventInfo!.unit == obj2.eventInfo!.unit && obj1.eventInfo!.cookingMethod == obj2.eventInfo!.cookingMethod);
  }

}
