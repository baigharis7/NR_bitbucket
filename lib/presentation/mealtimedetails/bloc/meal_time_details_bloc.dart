import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/delete_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/eventssync/update_events_interactor.dart';
import '../../../domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/macro_calculation_helper.dart';
import '../../../infrastructure/utils/constants.dart';

part 'meal_time_details_event.dart';
part 'meal_time_details_state.dart';

class MealTimeDetailsBloc extends Bloc<MealTimeDetailsEvent, MealTimeDetailsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final DeleteFoodEventInteractor deleteFoodEventInteractor;
  final RemoveFoodEventInteractor removeFoodEventInteractor;
  final UpdateEventsInteractor updateEventsInteractor;
  final PreferencesRepository preferencesRepository;
  final MacroCalculationHelper _macroHelper = const MacroCalculationHelper();
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  MealTimeDetailsBloc({
    required this.getUserIdInteractor,
    required this.getFoodEventsOfTodayInteractor,
    required this.getLiquidEventsOfTodayInteractor,
    required this.getProfileInteractor,
    required this.getMasterFileInteractor,
    required this.deleteFoodEventInteractor,
    required this.removeFoodEventInteractor,
    required this.updateEventsInteractor,
    required this.preferencesRepository,
}) : super(MealTimeDetailsState(isLoading: false)) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.food) {
        add(SummaryInitializationMealTimeDetailsEventState());
      }
    });
    on<InitialMealTimeDetailsEventState>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.profile = await getProfileInteractor.execute();
      state.profile?.kcal = getUserKcalSelectiveObjectives(state.profile?.kcal ?? 0);
      final foodNutrientsInfo = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.nutrientsInfoMaster = foodNutrientsInfo;
      final foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.foodNames = foodNames;
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);
      add(SummaryInitializationMealTimeDetailsEventState());
      emit(state.copyWith(isLoading: false));

      final shouldRefresh = await updateEventsInteractor.execute(userId: getUserIdInteractor.execute(), categoryType: PrefsKeys.foodEvents, fullSync: false);
      if (shouldRefresh) {
        add(SummaryInitializationMealTimeDetailsEventState());
        emit(state.copyWith(isLoading: false));
      }
    });

    on<SummaryInitializationMealTimeDetailsEventState>((event, emit) async {
      final a = await getFoodEventsOfTodayInteractor.execute(dateTime: state.selectedDateTime);
      state.foodEvents = a;
      state.foodEvents = state.foodEvents.orEmpty().where((foodEvent) => foodEvent.mealType == state.mealTime?.id.orZero()).toList();
      state.liquidEvents = await getLiquidEventsOfTodayInteractor.execute(dateTime: state.selectedDateTime);
      var totalSugarRequired = ((state.profile?.kcal ?? 0)*0.05)~/4;

      state.micronutrients = state.profile?.userAll.orEmpty()
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: 0,
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: 0,
            ),
      ).toList();

      state.macronutrients = ['proteinSci', 'carbsAvailable', 'fatTotal']
          .map(
            (macronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(macronutrient),
              nutrientInfoMaster: getNutrientInfo(macronutrient),
              fractionToFill: 0,
              unit: getUnitForMicronutrient(macronutrient),
              rda: getMacroNutrientRda(macronutrient),
              upperLimit: 0,
            ),
      ).toList();

      state.fiberSugar = [NutrientsModel(
        quantityConsumed: calculateTodayConsumedSugar(totalSugarRequired),
        nutrientInfoMaster: getNutrientInfo('addedSugar'),
        fractionToFill: 0,
        unit: 'g',
        rda: totalSugarRequired,
        upperLimit: 0,
      ), NutrientsModel(
        quantityConsumed: calculateTodayFiber(),
        nutrientInfoMaster: getNutrientInfo('fiber'),
        fractionToFill: 0,
        unit: 'g',
        rda: Constants.FIBER_TOTAL_REQUIRED,
        upperLimit: 0,
      ),];

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFoodArgumentsModelEventState>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.mealTime = event.foodArgumentsModel.mealTime;
      state.selectedDateTime = event.foodArgumentsModel.selectedDateTime;
      add(InitialMealTimeDetailsEventState(dateTime: state.selectedDateTime));
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateDateTimeMealTimeDetailsEvent>((event, emit) {
      state.selectedDateTime = event.dateTime;
      add(InitialMealTimeDetailsEventState(dateTime: state.selectedDateTime));

      emit(state.copyWith(isLoading: false));
    });

    on<DeleteFoodMealTimeDetailsEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodEventInteractor.execute(event.foodEventComplete.userId.orEmpty(), event.foodEventComplete.eventId!);
        try {
          await removeFoodEventInteractor.execute(event.foodEventComplete);
          DashboardEventBus.instance.notify(DataChangedCategory.food);
          add(SummaryInitializationMealTimeDetailsEventState());
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodEventError));
      }
    },);
  }

  double getQuantityConsumedSoFar(String micronutrient) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents.orEmpty()) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    return double.parse((nutrientQuantitySoFar).toStringAsFixed(2));
  }

  NutrientInfoMaster getNutrientInfo(String nutrientName) {
    NutrientInfoMaster nutrientInfo = NutrientInfoMaster(officialName: nutrientName, unit: '', en: '', es: '');
    for (var info in state.nutrientsInfoMaster?.nutrientsInfo ?? []) {
      if (info.officialName == nutrientName) {
        nutrientInfo = info;
      }
    }
    return nutrientInfo;
  }

  String getUnitForMicronutrient(String micronutrient) {
    var unit = '';
    for (var info in state.nutrientsInfoMaster?.nutrientsInfo ?? []) {
      if (info.officialName == micronutrient) {
        unit = info.unit;
      }
    }
    return unit;
  }

  num getNutrientRda(String micronutrient) {
    num rda = 0.0;
    loop:for (UserRda userRda in state.profile?.userRdas?.userRdas ?? []) {
      if (userRda.name == micronutrient) {
        rda = userRda.rda;
        break loop;
      }
    }
    return rda;
  }

  num getMacroNutrientRda(String macronutrient) {
    return _macroHelper.getMacroNutrientRda(
      state.profile?.kcal ?? 0,
      macronutrient,
      state.profile?.objectives ?? [],
    );
  }

  int getPercentageByMacro(String macro) {
    return _macroHelper.getPercentageByMacro(
      macro,
      state.profile?.objectives ?? [],
    );
  }

  int getKcalPerGram(String macro) => _macroHelper.getKcalPerGram(macro);

  int getUserKcalSelectiveObjectives(int userKcal) {
    return _macroHelper.getUserKcalSelectiveObjectives(
      userKcal,
      state.profile?.objectives ?? [],
    );
  }

  double calculateTodayConsumedSugar(int totalSugarRequired) {
    return _macroHelper.calculateConsumedSugar(
      state.foodEvents.orEmpty(),
      state.liquidEvents.orEmpty().cast<FoodEventComplete>(),
    );
  }

  double calculateTodayFiber() {
    return _macroHelper.calculateConsumedFiber(state.foodEvents.orEmpty());
  }



  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }

  bool _shouldCallAPI(DateTime? lastTime, DateTime? syncTime, Duration threshold) {
    if (lastTime == null || syncTime == null) return true; // first run
    final now = DateTime.now();
    bool isExpired1 = now.isAfter(lastTime.add(threshold));
    bool isExpired2 = now.isAfter(syncTime.add(threshold));
    return isExpired1 && isExpired2;
  }
}
