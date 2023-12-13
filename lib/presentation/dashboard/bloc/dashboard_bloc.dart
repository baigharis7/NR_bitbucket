import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_objectives_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/sugar_&_fiber_model.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';

import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import '../../../domain/interactor/sportevents/get_week_sports_interactor.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';

class DashboardBloc extends BaseBloc<DashboardActions, DashboardState> {
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserRdasInteractor getUserRdasInteractor;
  final GetAdviceInteractor getAdviceInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetDayCaloriesInteractor getDayCaloriesInteractor;
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetUserObjectivesInteractor getUserObjectivesInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;

  DashboardBloc({
    required this.getFoodEventsOfTodayInteractor,
    required this.getUserMicronutrientsInteractor,
    required this.getMasterFileInteractor,
    required this.getUserRdasInteractor,
    required this.getAdviceInteractor,
    required this.getUserIdInteractor,
    required this.getProfileInteractor,
    required this.getWaterEventsTodayInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getDayCaloriesInteractor,
    required this.getLiquidEventsOfTodayInteractor,
    required this.getUserObjectivesInteractor,
    required this.getWeekFoodEventsInteractor,
    required this.getWeekLiquidEventsInteractor,
    required this.getWeekSportsInteractor,
  }) : super(DashboardState(
    isLoading: false,
    advice: '',
    waterEvents: [],
    foodEvents: [],
    micronutrients: [],
    macronutrients: [],
    userKcal: 0,
    showCard: false,
  ),) {
    on<InitializeState>((event, emit) async {
      emit(DashboardState(isLoading: true));
      state.userMicronutrients = await getUserMicronutrientsInteractor.execute() ?? [];
      state.userRdas = await getUserRdasInteractor.execute();
      state.userObjectives = await getUserObjectivesInteractor.execute();
      state.foodEvents = await getFoodEventsOfTodayInteractor.execute();
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute();
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      state.weeklyLiquidEvents = await getWeekLiquidEventsInteractor.execute();
      state.weeklySportEvents = await getWeekSportsInteractor.execute();
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      final profile = await getProfileInteractor.execute();
      state.userKcal = profile!.kcal;
      state.micronutrients = state.userMicronutrients!
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
            ),
      ).toList();
      state.micronutrients?.sort((a, b) => b.fractionToFill.compareTo(a.fractionToFill),);
      state.macronutrients = ['proteinSci', 'carbsAvailable', 'fatTotal']
          .map(
            (macronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(macronutrient),
              nutrientInfoMaster: getNutrientInfo(macronutrient),
              fractionToFill: getFractionToFillMacros(macronutrient),
              unit: getUnitForMicronutrient(macronutrient),
            ),
      ).toList();
      final caloriesConsumed = await getDayCaloriesInteractor.execute();
      state.energyModel = EnergyModel(
        fractionToFill: getFractionToFillKcal(caloriesConsumed ?? 0),
        totalKcal: state.userKcal!,
        rawKcalTaken: getTotalKcalTakenToday(),
        spentKcal: caloriesConsumed ?? 0,
      );
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
      state.sugarAndFiberModel = SugarAndFiberModel(
          fractionToFillSugar: calculateTodaySugar(),
          totalSugar: calculateTodayConsumedSugar(),
          fractionToFillFiber: calculateTodayFiber(),
          totalFiber: calculateTodayConsumedFiber(),
      );
      state.weeklyMicronutrients = state.userRdas
          .orEmpty()
          .map((nutrientRda) => NutrientsModel(
          quantityConsumed: getWeeklyConsumedNutrient(nutrientRda),
          nutrientInfoMaster: getNutrientInfo(nutrientRda.name),
          fractionToFill: getWeeklyFractionFill(nutrientRda),
          unit: getUnitForMicronutrient(nutrientRda.name)))
          .toList();
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.dashboard.index);

      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    },);

    on<GetFoodEventsAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final foodEvents = await getFoodEventsOfTodayInteractor.execute();
        state.foodEvents = foodEvents;
        emit(state.copyWith(isLoading: false, onError: null));
      } catch (error) {
        state.onError = ErrorTypes.retrieveFoodEventsError;
        emit(state.copyWith(isLoading: false));
      }
    });

    on<HideCardAction>((event, emit) async {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.dashboard.index);
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<ReloadWaterInfoAction>((event, emit) async {
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
      emit(state.copyWith(isLoading: false, onError: null));
    });
  }

  NutrientInfoMaster getNutrientInfo(String nutrientName) {
    // final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo.firstWhere((info) => info.officialName == nutrientName);
    // return nutrientInfo;
    NutrientInfoMaster nutrientInfo = NutrientInfoMaster(officialName: nutrientName, unit: '', en: '', es: '');
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrientName) {
        nutrientInfo = info;
      }
    }
    return nutrientInfo;
  }

  // TODO: review this, dont know if ot's ok, just put it here to fit.
  double getFractionToFillMicros(String micronutrient) {
    final rdaForUser = state.userRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar + (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = nutrientQuantitySoFar / rdaForUser;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  double getFractionToFillMacros(String macronutrient) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[macronutrient] ?? 0.0);
      }
    }

    var tEE = state.userKcal ?? 0;
    if (state.userObjectives?.contains(50) ?? false) {
      tEE = tEE + tEE~/100*15;
    }
    if (state.userObjectives?.contains(51) ?? false) {
      tEE = tEE - tEE~/100*20;
    }
    int kcalPerNutrient = tEE~/100 * getPercentageByMacro(macronutrient);
    int gramsPerNutrient = kcalPerNutrient ~/ getKcalPerGram(macronutrient);
    double returnQuantity = nutrientQuantitySoFar / gramsPerNutrient;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  double getFractionToFillKcal(int caloriesConsumed) {
    const kcalName = 'energyKcal';
    double kcalQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        kcalQuantitySoFar = kcalQuantitySoFar + (food.params!.toJson()[kcalName] ?? 0.0);
      }
    }

    double returnQuantity = (kcalQuantitySoFar.toInt() + getTodayKcalFromLiquids(state.todayLiquidEvents!)) / (state.userKcal! + caloriesConsumed);
    if (returnQuantity > 1) returnQuantity = 1;
    if (returnQuantity < 0) returnQuantity = 0.0;
    return returnQuantity;
  }

  int getTotalKcalTakenToday() {
    const kcalName = 'energyKcal';
    double kcalQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        kcalQuantitySoFar = kcalQuantitySoFar + (food.params!.toJson()[kcalName] ?? 0.0);
      }
    }
    return kcalQuantitySoFar.toInt() + getTodayKcalFromLiquids(state.todayLiquidEvents!);
  }

  double getQuantityConsumedSoFar(String micronutrient) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    return double.parse((nutrientQuantitySoFar).toStringAsFixed(2));
  }

  double calculateTodaySugar() {
    double sugarConsumedToday = 0.0;
    for(var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        sugarConsumedToday = sugarConsumedToday + (food.params?.sugarsTotal ?? 0.0);
      }
    }

    for(var liquidEvent in state.todayLiquidEvents!) {
      for (var liquid in liquidEvent.foodInfo!) {
        sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
      }
    }

    sugarConsumedToday = sugarConsumedToday/20;
    if (sugarConsumedToday > 1) sugarConsumedToday = 1;
    if (sugarConsumedToday < 0) sugarConsumedToday = 0.0;
    return double.parse(sugarConsumedToday.toStringAsFixed(2));
  }

  double calculateTodayConsumedSugar() {
    double sugarConsumedToday = 0.0;
    for(var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        sugarConsumedToday = sugarConsumedToday + (food.params?.sugarsTotal ?? 0.0);
      }
    }

    for(var liquidEvent in state.todayLiquidEvents!) {
      for (var liquid in liquidEvent.foodInfo!) {
        sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
      }
    }

    var tEE = state.userKcal ?? 0;
    tEE = tEE~/100*5;
    sugarConsumedToday = (sugarConsumedToday*4)/tEE;
    sugarConsumedToday = sugarConsumedToday/4;
    return double.parse(sugarConsumedToday.toStringAsFixed(2));
  }

  double calculateTodayFiber() {
    double fiberConsumedToday = 0.0;
    for(var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        fiberConsumedToday = fiberConsumedToday + (food.params?.fiber ?? 0.0);
      }
    }

    fiberConsumedToday = fiberConsumedToday/25;
    if (fiberConsumedToday > 1) fiberConsumedToday = 1;
    if (fiberConsumedToday < 0) fiberConsumedToday = 0.0;
    return double.parse(fiberConsumedToday.toStringAsFixed(2));
  }

  double calculateTodayConsumedFiber() {
    double fiberConsumedToday = 0.0;
    for(var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        fiberConsumedToday = fiberConsumedToday + (food.params?.fiber ?? 0.0);
      }
    }

    fiberConsumedToday = fiberConsumedToday/25;
    return double.parse(fiberConsumedToday.toStringAsFixed(2));
  }

  int getTodayKcalFromLiquids(List<FoodEventComplete> events) {
    int kcals = 0;
    for (var event in events) {
      kcals = kcals + event.eventKcals!;
    }

    return kcals;
  }

  String getUnitForMicronutrient(String micronutrient) {
    // final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo.firstWhere((info,) => info.officialName == micronutrient);
    // return nutrientInfo.unit;
    var unit = '';
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == micronutrient) {
        unit = info.unit;
      }
    }
    return unit;
  }

  int getPercentageByMacro(String macro) {
    var macroo = 0;
    if (state.userObjectives?.contains(50) ?? false) {
      macroo = macro == 'carbsAvailable' ? 40 : 30;
    }
    if(state.userObjectives?.contains(51) ?? false) {
      macroo = macro == 'carbsAvailable' ? 40 : 30;
    }
    if(state.userObjectives?.contains(52) ?? false) {
      macroo = macro == 'carbsAvailable' ? 50 : macro == 'proteinSci' ? 20 : 30;
    }
    else {
      macroo = macro == 'carbsAvailable' ? 30 : 35;
    }
    return macroo;
  }

  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 30 : 35;
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 40 : 30; (For gain Muscle's) - Objectives-50
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 40 : 30; (Lose fat) - Objectives-51
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 50 : macro == 'proteinSci' ? 20 : 30; (Maintain Weight) - Objectives-52
  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  double getWeeklyConsumedNutrient(UserRda nutrientRda) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.weeklyFoodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[nutrientRda.name] ?? 0.0);
      }
    }

    return double.parse((nutrientQuantitySoFar).toStringAsFixed(2));
  }

  getWeeklyFractionFill(UserRda nutrientRda) {
    final perRdaForUser = state.userRdas!.firstWhere((rda) => rda.name == nutrientRda.name).rda;
    double weeklyNutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.weeklyFoodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        weeklyNutrientQuantitySoFar = weeklyNutrientQuantitySoFar + (food.params!.toJson()[nutrientRda.name] ?? 0.0);
      }
    }

    weeklyNutrientQuantitySoFar = weeklyNutrientQuantitySoFar/7;
    if (weeklyNutrientQuantitySoFar < perRdaForUser) {
      weeklyNutrientQuantitySoFar = weeklyNutrientQuantitySoFar / perRdaForUser;
    }
    if (weeklyNutrientQuantitySoFar > perRdaForUser) {
      weeklyNutrientQuantitySoFar = 1.0;
    }
    if (weeklyNutrientQuantitySoFar < 0 ) {
      weeklyNutrientQuantitySoFar = 0.0;
    }
    return weeklyNutrientQuantitySoFar;
  }
}