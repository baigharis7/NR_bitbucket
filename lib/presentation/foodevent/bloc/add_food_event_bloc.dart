import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_items_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor.dart';
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
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';

import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodroutine/food_routine_event.dart';

class AddFoodEventBloc extends BaseBloc<AddFoodEventActions, AddFoodEventState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final UploadFoodFavoriteInteractor uploadFoodFavoriteInteractor;
  final SaveFoodFavoriteInteractor saveFoodFavoriteInteractor;
  final UploadFoodRoutineInteractor uploadFoodRoutineInteractor;
  final SaveFoodRoutineInteractor saveFoodRoutineInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor;
  final GetRecentFoodItemsInteractor getRecentFoodItemsInteractor;

  AddFoodEventBloc({
    required this.getUserIdInteractor,
    required this.saveFoodEventInteractor,
    required this.uploadFoodEventInteractor,
    required this.getMasterFileInteractor,
    required this.getFoodFavoritesInteractor,
    required this.getWeekFoodEventsInteractor,
    required this.uploadFoodFavoriteInteractor,
    required this.saveFoodFavoriteInteractor,
    required this.uploadFoodRoutineInteractor,
    required this.saveFoodRoutineInteractor,
    required this.deleteFoodFavoriteInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
    required this.getRecentFoodItemsInteractor,
  }) : super(AddFoodEventState(
    isLoading: false,
    foodNames: FoodsAndDrinksNamesMaster(
      FoodsAndDrinkListsMaster(
        foodNames: [],
        drinkNames: [],
      ),
    ),
    foodEvent: FoodFavorite.empty(),
    isEdit: false,
    cookingMethodsInfoMaster: CookingMethodsInfoMaster(cookingMethodsInfo: []),
    cookingMethodsMaster: CookingMethodsMaster(cookingMethods: []),
    unitsFoodsMaster: UnitsFoodsMaster(unitsFoodsMaster: []),
    unitsInfoMaster: UnitsInfoMaster(unitsInfoMaster: []),
  ),) {

    on<InitializeStateAction>((event, emit) async {
      _clearFields();
      emit(state.copyWith(isLoading: true,  onError: null));
      if (state.foodNames!.foodsAndDrinksNames!.foodNames!.isEmpty) {
        final foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
        state.foodNames = foodNames;
        state.foodNames?.foodsAndDrinksNames?.foodNames?.removeWhere((f) => f.included == 1);
        state.foodNames?.foodsAndDrinksNames?.drinkNames?.removeWhere((f) => f.included == 1);
        state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);
      }
      final foodOils = await getMasterFileInteractor.execute(MasterFilesType.oilTypes);
      state.oilTypes = foodOils;
      state.conversionFactors = await getMasterFileInteractor.execute(MasterFilesType.conversionFactors);
      if (state.cookingMethodsInfoMaster!.cookingMethodsInfo!.isEmpty) {
        final a = await getMasterFileInteractor.execute(MasterFilesType.cookingMethodsInfo);
        state.cookingMethodsInfoMaster = a;
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
      state.foodFavorites = state.foodFavorites.orEmpty().where((foodFav) => foodFav.mealTime == state.foodEvent?.mealTime).toList();
      final allRecent = await getRecentFoodItemsInteractor.execute();
      state.recentFoodItems = allRecent.where((item) => item.mealTime == state.foodEvent?.mealTime).toList();

      emit(state.copyWith(isLoading: false,));
    },);

    on<SwitchFavRecentTabAction>((event, emit) {
      state.favRecentTab = event.tabIndex;
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateEventDateEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      state.foodEvent!.eventDate = event.dateTime.millisecondsSinceEpoch;
      emit(state.copyWith(isLoading: false,));
    },);

    on<RemoveFoodFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      // state.foodsInEvent!.remove(event.foodInEvent);

      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
      }

      emit(state.copyWith(isLoading: false,));
    });

    on<AddFoodFromEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients.remove(state.foodEvent!.ingredients[itemIndex]);
        state.foodEvent!.ingredients.add(event.foodInEvent);
      } else {
        state.foodEvent!.ingredients.add(event.foodInEvent);
      }
      emit(state.copyWith(isLoading: false,));
    });

    on<UpdateFoodQuantityEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].qty = event.foodInEvent.qty;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateFoodUnitEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].unit = event.foodInEvent.unit;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateFoodConversionFactor>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        final item = state.foodEvent!.ingredients[itemIndex];
        item.conversionFactor = event.foodInEvent.conversionFactor;
        item.cookingMethod = -1;
        item.usedOil = 0;
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFoodCookingMethodEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].cookingMethod = event.foodInEvent.cookingMethod;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateOilUsedEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.ingredients.map((food) => food.id).contains((event.foodInEvent).id)) {
        final itemIndex = state.foodEvent!.ingredients.indexOf(state.foodEvent!.ingredients.firstWhere((food) => food.id == event.foodInEvent.id));
        state.foodEvent!.ingredients[itemIndex].usedOil = event.foodInEvent.usedOil;
      }

      emit(state.copyWith(isLoading: false,));
    });

    on<AddFoodNameEventAction>((event, emit) {
      state.foodEvent!.title = event.foodName;

      emit(state.copyWith(isLoading: false, onError: null,));
    },);

    on<UpdateIsFavoriteEventAction>((event, emit) {
      state.foodEvent?.isFavorite = (state.foodEvent?.isFavorite ?? false) ? false : true;

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateIsCreateRoutineEventAction>((event, emit) {
      state.foodEvent!.isRoutine = (state.foodEvent!.isRoutine ?? false) ? false : true;

      // Auto-initialize time for snack routines (snack mealTime == 3 has no default time)
      if (state.foodEvent!.isRoutine == true && state.foodEvent?.mealTime == 3 && state.foodEvent?.time.isEmptyOrNull() == true) {
        state.foodEvent?.time = DateTimeHelper.timeOfDayTo24HrString(TimeOfDay.now());
      }

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<UpdateScheduleTimeAddFoodEventActions>((event, emit) {
      state.foodEvent?.time = event.scheduleTime;

      emit(state.copyWith(isLoading: false));
    });

    on<AddFoodMealTypeEventAction>((event, emit) {
      state.foodEvent?.mealTime = event.mealType;
      emit(state.copyWith(isLoading: false, onError: null,));
    },);

    on<UpdateDaysOfWeekEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.foodEvent!.daysOfWeek.orEmpty().contains(event.day)) {
        state.foodEvent!.daysOfWeek?.remove(event.day);
      } else {
        state.foodEvent!.daysOfWeek?.add(event.day);
      }

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateCreteDishEventAction>((event, emit) {
      state.foodEvent!.dish = (state.foodEvent!.dish ?? false) ? false : true;

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<AddFoodFromFavouriteEventAction>((event, emit) {
      final isSame = state.foodsFromFavorite == event.foodFavorite;
      state.foodsFromFavorite = isSame ? null : event.foodFavorite;
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<AddFoodArgumentModelEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      state.foodEvent?.mealTime = event.foodArgumentsModel.mealTime.id;
      state.foodEvent?.eventDate = event.foodArgumentsModel.selectedDateTime.millisecondsSinceEpoch;
      state.foodEvent?.time = event.foodArgumentsModel.mealTime.time;
      if (event.foodArgumentsModel.preSelectFavorite) {
        state.foodEvent?.isFavorite = true;
      }
      if (event.foodArgumentsModel.preSelectRoutine) {
        state.foodEvent?.isRoutine = true;
      }
      // Re-filter favorites and recents for the correct mealTime
      final allFavorites = await getFoodFavoritesInteractor.execute();
      state.foodFavorites = allFavorites.orEmpty().where((foodFav) => foodFav.mealTime == state.foodEvent?.mealTime).toList();
      final allRecent = await getRecentFoodItemsInteractor.execute();
      state.recentFoodItems = allRecent.where((item) => item.mealTime == state.foodEvent?.mealTime).toList();
      emit(state.copyWith(isLoading: false,));
    },);

    on<UpdateFoodDataFromFavoritesAddFoodEventActions>((event, emit) {
      final item = event.foodFavorite;
      item.isFavorite = true;
      state.foodEvent = item;
      state.isEdit = true;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<PrefillFoodFromScanAction>((event, emit) {
      final item = event.foodFavorite;
      item.isFavorite = false;
      item.isRoutine = false;
      state.foodEvent = item;
      state.isEdit = false;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<PrefillFoodForRoutineAction>((event, emit) {
      final item = event.foodFavorite;
      item.isRoutine = true;
      item.isFavorite = false;
      item.mealTime = item.mealTime ?? state.foodEvent?.mealTime;
      item.eventDate = item.eventDate ?? state.foodEvent?.eventDate;
      item.daysOfWeek = item.daysOfWeek ?? [];
      state.foodEvent = item;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<PrefillFoodForFavoriteAction>((event, emit) {
      final item = event.foodFavorite;
      item.isFavorite = true;
      item.isRoutine = false;
      item.mealTime = item.mealTime ?? state.foodEvent?.mealTime;
      item.eventDate = item.eventDate ?? state.foodEvent?.eventDate;
      state.foodEvent = item;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<PrefillFoodForCustomizeAction>((event, emit) {
      final item = event.foodFavorite;
      item.isFavorite = false;
      item.isRoutine = false;
      item.mealTime = item.mealTime ?? state.foodEvent?.mealTime;
      item.eventDate = item.eventDate ?? state.foodEvent?.eventDate;
      state.foodEvent = item;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateFoodRoutineFromRoutines>((event, emit) {
      final item = mapToFoodFavoriteFromRoutine(event.foodRoutineEvent);
      item.isRoutine = true;
      state.foodEvent = item;
      state.isEdit = true;
      emit(state.copyWith(isLoading: false));
    });

    on<FinishFoodAsFavoriteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        event.foodFavorite.userId = getUserIdInteractor.execute();
        event.foodFavorite.eventId = event.foodFavorite.eventId ?? DateTime.now().millisecondsSinceEpoch;
        event.foodFavorite.eventDate = event.foodFavorite.eventDate ?? DateTime.now().millisecondsSinceEpoch;

        final uploadFoodAsFavorite = await uploadFoodFavoriteInteractor.execute(event.foodFavorite);
        try {
          final saveFoodsAsFavorite = await saveFoodFavoriteInteractor.execute(event.foodFavorite, state.isEdit!);
          state.foodFavorites = await getFoodFavoritesInteractor.execute();
          state.foodFavorites = state.foodFavorites.orEmpty().where((foodFav) => foodFav.mealTime == state.foodEvent?.mealTime).toList();

          // Also log the item as an event
          try {
            final foodEventSimple = mapToFoodEventSimpleFromFoodFavorite(state.foodEvent!);
            foodEventSimple.eventId = DateTime.now().millisecondsSinceEpoch;
            foodEventSimple.userId = getUserIdInteractor.execute();
            foodEventSimple.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
            final uploadFoodEvent = await uploadFoodEventInteractor.execute(foodEventSimple);
            if (uploadFoodEvent.uploadSuccess) {
              await saveFoodEventInteractor.execute(uploadFoodEvent, false);
              DashboardEventBus.instance.notify(DataChangedCategory.food);
            }
          } catch (error, st) {
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Food event logging alongside favorite',
                'screen': 'Add Food',
                'event data': event.foodFavorite.toJson().toString(),
              },
            );
          }

          _clearFields();
          emit(state.copyWith(isLoading: false, onError: null,));
          event.onFinish.call();
        } catch (error, st) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
          CrashlyticsService.record(
            error,
            st,
            context: {
              'action': 'Food favorite logging local',
              'screen': 'Add Food',
              'event data': event.foodFavorite.toJson().toString(),
            },
          );
        }
      } catch (error, st){
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodFavoriteError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Food favorite logging',
            'screen': 'Add Food',
            'event data': event.foodFavorite.toJson().toString(),
          },
        );
      }
    });

    on<RemoveFavoriteFoodAddFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        await deleteFoodFavoriteInteractor.execute(getUserIdInteractor.execute(), event.foodFavorite.eventId.orZero());
        try {
          await removeFoodFavoriteFromLocalInteractor.execute(event.foodFavorite);
          state.foodFavorites = await getFoodFavoritesInteractor.execute();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    });

    on<FinishFoodFavouriteEventAction>((event, emit) async {
      state.foodsFromFavorite?.userId = getUserIdInteractor.execute();
      state.foodsFromFavorite?.eventId = DateTime.now().millisecondsSinceEpoch;
      state.foodsFromFavorite?.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
      // state.foodsFromFavorite?.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
      if (state.foodsFromFavorite?.isRoutine == true && state.foodsFromFavorite?.daysOfWeek?.isNotEmpty == true) {
        final foodEventRoutine = mapToFoodRoutineEventFromFoodFavorite(state.foodsFromFavorite!);
        add(FinishAddFoodRoutineEventAction(foodRoutineEvent: foodEventRoutine, onFinish: event.onFinish));
      } else {
        final foodEventSimple = mapToFoodEventSimpleFromFoodFavorite(state.foodsFromFavorite!);
        add(FinishAddFoodEventAction(foodEventSimple: foodEventSimple, onFinish: event.onFinish));
      }
    },);

    on<FinishFoodEventAddFoodEventActions>((event, emit) async {
      state.foodEvent?.userId = getUserIdInteractor.execute();
      state.foodEvent?.eventId = state.foodEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
      state.foodEvent?.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;

      state.foodEvent?.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
      state.foodEvent?.time = state.foodEvent?.time ?? DateFormat.Hm().format(DateTime.now().add(const Duration(minutes: 10)));
      if (state.foodEvent?.isFavorite ?? false) {
        add(FinishFoodAsFavoriteEventAction(foodFavorite: state.foodEvent!, onFinish: event.onFinish));
      }
      else if (state.foodEvent?.isRoutine == true && state.foodEvent?.daysOfWeek?.isNotEmpty == true) {
        final foodEventRoutine = mapToFoodRoutineEventFromFoodFavorite(state.foodEvent!);
        add(FinishAddFoodRoutineEventAction(foodRoutineEvent: foodEventRoutine, onFinish: event.onFinish));
      } else {
        final foodEventSimple = mapToFoodEventSimpleFromFoodFavorite(state.foodEvent!);
        add(FinishAddFoodEventAction(foodEventSimple: foodEventSimple, onFinish: event.onFinish));
      }
    });

    on<FinishAddFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        event.foodEventSimple.userId = getUserIdInteractor.execute();
        event.foodEventSimple.eventId = state.foodEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        event.foodEventSimple.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;

        final uploadFoodEvent = await uploadFoodEventInteractor.execute(event.foodEventSimple);
        if (uploadFoodEvent.uploadSuccess) {
          try {
            await saveFoodEventInteractor.execute(uploadFoodEvent, state.isEdit!);
            DashboardEventBus.instance.notify(DataChangedCategory.food);

            _clearFields();
            emit(state.copyWith(isLoading: false,));
            event.onFinish.call();
          } catch (error, st) {
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Food logging local',
                'screen': 'Add Food',
                'event data': event.foodEventSimple.toJson().toString(),
              },
            );
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.locallySavingFoodEventError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodEventError));
        }
      } catch (error, st) {
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Food logging',
            'screen': 'Add Food',
            'event data': event.foodEventSimple.toJson().toString(),
          },
        );
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodEventError));
      }
    });

    on<FinishAddFoodRoutineEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        event.foodRoutineEvent.userId = getUserIdInteractor.execute();
        event.foodRoutineEvent.eventId = state.foodEvent?.eventId ?? DateTime.now().millisecondsSinceEpoch;
        event.foodRoutineEvent.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;

        event.foodRoutineEvent.timeZone = await DateTimeHelper.getDeviceIANATimeZone();
        if (event.foodRoutineEvent.time.isEmptyOrNull() == true) {
          event.foodRoutineEvent.time = DateFormat.Hm().format(DateTime.now().add(const Duration(minutes: 10)));
        }
        // event.foodRoutineEvent.time = state.foodEvent?.time ?? DateFormat.Hm().format(DateTime.now().add(const Duration(minutes: 10)));

        final uploadedRoutine = await uploadFoodRoutineInteractor.execute(event.foodRoutineEvent);
        if (uploadedRoutine) {
          try {
            await saveFoodRoutineInteractor.execute(event.foodRoutineEvent, state.isEdit ?? false);
            DashboardEventBus.instance.notify(DataChangedCategory.food);

            _clearFields();
            emit(state.copyWith(isLoading: false, onError: null,));
            event.onFinish.call();
          } catch (error, st) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveFoodRoutineEventError));
            CrashlyticsService.record(
              error,
              st,
              context: {
                'action': 'Food routine logging local',
                'screen': 'Add Food',
                'event data': event.foodRoutineEvent.toJson().toString(),
              },
            );
          }

        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodRoutineEventError));
        }
      } catch (error, st) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingFoodRoutineEventError));
        CrashlyticsService.record(
          error,
          st,
          context: {
            'action': 'Food routine logging',
            'screen': 'Add Food',
            'event data': event.foodRoutineEvent.toJson().toString(),
          },
        );
      }
    });

    on<ResetFoodEventInfoAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null, isEdit: false,));
    });

  }

  void _clearFields() {
    state.foodEvent = FoodFavorite.empty(eventData: state.foodEvent?.eventDate, mealTime: state.foodEvent?.mealTime);
    state.foodsFromFavorite = FoodFavorite.empty(eventData: state.foodsFromFavorite?.eventDate, mealTime: state.foodsFromFavorite?.mealTime);
    state.isEdit = false;
    state.onError = null;
    // state.eventDate = null;
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
     return state.foodEvent?.ingredients.any((food) {
      return food.qty <= 0 || food.unit == -1;
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

  List<FoodFavorite> getFoodListByType(MealTime mealTime) {
    final list = <FoodFavorite>[];
    for (var favorite in state.foodFavorites.orEmpty()) {
      if (favorite.mealTime == mealTime.id) {
        list.add(favorite);
      }
    }
    return list;
  }

}
