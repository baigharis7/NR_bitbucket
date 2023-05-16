import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';

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
      state.foodEvents = await getFoodEventsOfTodayInteractor.execute();
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
        fractionToFill: getFractionToFillKcal(),
        totalKcal: state.userKcal!,
        rawKcalTaken: getTotalKcalTakenToday(),
        spentKcal: caloriesConsumed ?? 0,
      );
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
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
    final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo.firstWhere((info) => info.officialName == nutrientName);
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

    int kcalPerNutrient = state.userKcal!~/100 * getPercentageByMacro(macronutrient);
    int gramsPerNutrient = kcalPerNutrient ~/ getKcalPerGram(macronutrient);
    double returnQuantity = nutrientQuantitySoFar / gramsPerNutrient;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  double getFractionToFillKcal() {
    const kcalName = 'energyKcal';
    double kcalQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        kcalQuantitySoFar = kcalQuantitySoFar + (food.params!.toJson()[kcalName] ?? 0.0);
      }
    }

    double returnQuantity = kcalQuantitySoFar.toInt() / state.userKcal!;
    if (returnQuantity > 1) returnQuantity = 1;
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
    return kcalQuantitySoFar.toInt();
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

  String getUnitForMicronutrient(String micronutrient) {
    final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo.firstWhere((info,) => info.officialName == micronutrient);
    return nutrientInfo.unit;
  }

  int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 30 : 35;
  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}