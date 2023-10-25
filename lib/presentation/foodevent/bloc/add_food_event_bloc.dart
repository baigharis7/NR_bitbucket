import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';

class AddFoodEventBloc extends BaseBloc<AddFoodEventActions, AddFoodEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;

  AddFoodEventBloc({
    required this.getUserIdInteractor,
    required this.saveFoodEventInteractor,
    required this.uploadFoodEventInteractor,
    required this.getMasterFileInteractor,
    required this.getFoodFavoritesInteractor,
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

    on<AddFoodNameEventAction>((event, emit) {
      state.foodName = event.foodName;
      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    },);

    on<SelectCookingMethodAction>((event, emit) {
      state.foodsInEvent!.add(event.foodInEvent);
      emit(state.copyWith(isLoading: false, onError: null, eventDate: state.eventDate));
    });

    on<FinishFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, eventDate: state.eventDate));

      final foodEvent = FoodEventSimple(
          userId: getUserIdInteractor.execute(),
          eventDate: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
        foodName: state.foodName ?? '',
      );
      foodEvent.ingredients = state.foodsInEvent.orEmpty();
      foodEvent.drinks = []; // TODO: is it necessary to implement drinks in food events?

      try {
        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEvent);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);
            state.foodsInEvent!.clear();
            state.foodName = '';
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

    on<ValidateListEventAction>((event, emit) {
      state.foodsInEvent = state.foodsInEvent?.map((food) {
        return FoodInEvent(id: food.id, qty: food.qty, unit: food.unit, errorFood: food.qty < 0 ? true : false, cookingMethod: food.cookingMethod, );
      },).toList();
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    },);

    on<AddFoodFromFavouriteEventAction>((event, emit) {
      state.foodName = event.foodFavorite.title;
      state.foodsFromFavorite = event.foodFavorite.ingredients.map((item) {
        return FoodInEvent(id: item.id, qty: item.qty, unit: item.unit, cookingMethod: item.cookingMethod);
      },).toList();
      emit(state.copyWith(isLoading: false, eventDate: state.eventDate));
    },);

    on<FinishFoodFavouriteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, eventDate: state.eventDate));

      final foodEvent = FoodEventSimple(
        userId: getUserIdInteractor.execute(),
        eventDate: DateTime.now().millisecondsSinceEpoch,
        eventId: DateTime.now().millisecondsSinceEpoch,
        foodName: state.foodName ?? '',
      );
      foodEvent.ingredients = state.foodsFromFavorite.orEmpty();
      foodEvent.drinks = []; // TODO: is it necessary to implement drinks in food events?

      try {
        final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEvent);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);
            state.foodsFromFavorite!.clear();
            state.foodName = '';
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

}
