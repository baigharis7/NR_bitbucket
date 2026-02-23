import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_rdas_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_weekly_model.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import '../../../domain/interactor/sportevents/get_week_sports_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/helpers/macro_calculation_helper.dart';

part 'weekly_dashboard_detail_event.dart';

part 'weekly_dashboard_detail_state.dart';

class WeeklyDashboardDetailBloc
    extends Bloc<WeeklyDashboardDetailEvent, WeeklyDashboardDetailState> {
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor;
  final GetUserRdasInteractor getUserRdasInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final MacroCalculationHelper _macroHelper = const MacroCalculationHelper();
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  WeeklyDashboardDetailBloc(
      {required this.getWeekFoodEventsInteractor,
      required this.getUserMicronutrientsInteractor,
      required this.getUserRdasInteractor,
      required this.getProfileInteractor,
      required this.getMasterFileInteractor,
      required this.getWeekLiquidEventsInteractor,
      required this.getWeekSportsInteractor})
      : super(WeeklyDashboardDetailState(isLoading: false)) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.food ||
          category == DataChangedCategory.sport ||
          category == DataChangedCategory.liquid) {
        add(InitialStateEventAction());
      }
    });

    on<InitialStateEventAction>((event, emit) async {
      state.userMicronutrients =
          await getUserMicronutrientsInteractor.execute();
      state.userRdas = await getUserRdasInteractor.execute();
      state.nutrientsInfoMaster =
          await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      state.userProfile = await getProfileInteractor.execute();
      state.weeklyLiquidEvents = await getWeekLiquidEventsInteractor.execute();
      state.weeklySportEvents = await getWeekSportsInteractor.execute();
      state.micronutrientsWeekly = state.userMicronutrients!
          .map(
            (micronutrient) => NutrientsWeeklyModel(
                nutrientInfoMaster: getNutrientInfo(micronutrient),
                weeklyData: getWeeklyMicroNutrientsDataFormatted(
                    state.weeklyFoodEvents ?? [], micronutrient)),
          )
          .toList();
      state.macronutrientsWeekly = ['proteinSci', 'carbsAvailable', 'fatTotal']
          .map(
            (macronutrient) => NutrientsWeeklyModel(
                nutrientInfoMaster: getNutrientInfo(macronutrient),
                weeklyData: getWeeklyMacroNutrientsDataFormatted(
                    state.weeklyFoodEvents ?? [], macronutrient)),
          )
          .toList();
      state.averageConsumedKcal = consumedKcal();
      state.averageSpentKcal = spentKcal();
      state.weeklyEnergyBalance = getWeeklyEnergyLevel();

      emit(state.copyWith(isLoading: false));
    });
  }

  double getQuantityConsumedSoFar(String micronutrient) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.weeklyFoodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    return double.parse((nutrientQuantitySoFar).toStringAsFixed(2));
  }

  NutrientInfoMaster getNutrientInfo(String nutrientName) {
    final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo
        .firstWhere((info) => info.officialName == nutrientName);
    return nutrientInfo;
  }

  double getFractionToFillMicros(String micronutrient) {
    final rdaForUser =
        state.userRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.weeklyFoodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = nutrientQuantitySoFar / rdaForUser;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  String getUnitForMicronutrient(String micronutrient) {
    final nutrientInfo = state.nutrientsInfoMaster!.nutrientsInfo.firstWhere((
      info,
    ) =>
        info.officialName == micronutrient);
    return nutrientInfo.unit;
  }

  List<Map<String, dynamic>> getWeeklyMicroNutrientsDataFormatted(
      List<FoodEventComplete> completeWeekData, String micronutrient) {
    final rdaForUser =
        state.userRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in completeWeekData) {
      int weekDay =
          DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <FoodEventComplete>[];
      for (var event in completeWeekData) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfWeekDay.add(event);
        }
      }
      double nutrientConsumed = 0;
      for (var event in eventsOfWeekDay) {
        for (var info in event.foodInfo!) {
          nutrientConsumed =
              nutrientConsumed + (info.params?.toJson()[micronutrient] ?? 0.0);
        }
      }
      // weeklyData.add({'day': eventWeekDay, 'kcal': EventsHelper().getFractionToFillKcal(nutrientConsumed, state.userProfile?.kcal ?? 0)});
      nutrientConsumed = nutrientConsumed / rdaForUser;
      if (nutrientConsumed > 1) nutrientConsumed = 1;
      if (nutrientConsumed < 0) nutrientConsumed = 0.0;
      weeklyData
          .add({'day': eventWeekDay, 'nutrientConsumed': nutrientConsumed});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  List<Map<String, dynamic>> getWeeklyMacroNutrientsDataFormatted(
      List<FoodEventComplete> completeWeekData, String macronutrient) {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in completeWeekData) {
      int weekDay =
          DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <FoodEventComplete>[];
      for (var event in completeWeekData) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfWeekDay.add(event);
        }
      }
      double nutrientConsumed = 0;
      for (var event in eventsOfWeekDay) {
        for (var info in event.foodInfo!) {
          nutrientConsumed =
              nutrientConsumed + (info.params?.toJson()[macronutrient] ?? 0.0);
        }
      }
      var tEE = _macroHelper.getUserKcalSelectiveObjectives(
        state.userProfile?.kcal ?? 0,
        state.userProfile?.objectives ?? [],
      );
      int kcalPerNutrient = tEE ~/ 100 * getPercentageByMacro(macronutrient);
      int gramsPerNutrient = kcalPerNutrient ~/ getKcalPerGram(macronutrient);
      double returnQuantity = nutrientConsumed / gramsPerNutrient;
      if (returnQuantity > 1) returnQuantity = 1;
      if (returnQuantity < 0) returnQuantity = 0.0;
      weeklyData.add({'day': eventWeekDay, 'nutrientConsumed': returnQuantity});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  int getPercentageByMacro(String macro) {
    return _macroHelper.getPercentageByMacro(
      macro,
      state.userProfile?.objectives ?? [],
    );
  }

  int getKcalPerGram(String macro) => _macroHelper.getKcalPerGram(macro);

  List<Map<String, dynamic>> getWeeklyEnergyLevel() {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in state.weeklyFoodEvents ?? []) {
      int weekDay =
          DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      //FoodEvents
      final eventsOfFoodWeekDay = <FoodEventComplete>[];
      for (var event in state.weeklyFoodEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfFoodWeekDay.add(event);
        }
      }
      double nutrientConsumed = 0;
      for (var event in eventsOfFoodWeekDay) {
          nutrientConsumed =
              nutrientConsumed + (event.eventKcals ?? 0.0);
      }

      //LiquidEvents
      final eventsOfLiquidWeekDay = <FoodEventComplete>[];
      for (var event in state.weeklyLiquidEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfLiquidWeekDay.add(event);
        }
      }
      double liquidConsumed = 0;
      for (var event in eventsOfLiquidWeekDay) {
        liquidConsumed =
            liquidConsumed + (event.eventKcals ?? 0.0);
      }

      //SportEvents
      final eventsOfSportWeekDay = <SportEventComplete>[];
      for (var event in state.weeklySportEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfSportWeekDay.add(event);
        }
      }
      double sportConsumed = 0;
      for (var event in eventsOfSportWeekDay) {
        sportConsumed =
            sportConsumed + (event.eventKcals ?? 0.0);
      }

      var totalEnergyBalance = (nutrientConsumed + liquidConsumed - sportConsumed) / (state.userProfile?.kcal ?? 0);
      if (totalEnergyBalance > 1) totalEnergyBalance = 1;
      if (totalEnergyBalance < 0) totalEnergyBalance = 0.0;
      weeklyData
          .add({'day': eventWeekDay, 'Kcal': totalEnergyBalance});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  double consumedKcal() {
    double foodKcalConsumed = 0;
    for (var event in state.weeklyFoodEvents ?? []) {
      foodKcalConsumed =
          foodKcalConsumed + (event.eventKcals ?? 0.0);
    }

    double liquidKcalConsumed = 0;
    for (var event in state.weeklyLiquidEvents ?? []) {
      liquidKcalConsumed =
          liquidKcalConsumed + (event.eventKcals ?? 0.0);
    }
    return foodKcalConsumed+liquidKcalConsumed;
  }

  double spentKcal() {
    double sportKcalConsumed = 0;
    for (var event in state.weeklySportEvents ?? []) {
      sportKcalConsumed =
          sportKcalConsumed + (event.eventKcals ?? 0.0);
    }
    return sportKcalConsumed;
  }

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}
