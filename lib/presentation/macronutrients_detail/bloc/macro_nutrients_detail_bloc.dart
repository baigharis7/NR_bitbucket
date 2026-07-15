import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/utils/constants.dart';

part 'macro_nutrients_detail_event.dart';
part 'macro_nutrients_detail_state.dart';

class MacroNutrientsDetailBloc extends Bloc<MacroNutrientsDetailEvent, MacroNutrientsDetailState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  MacroNutrientsDetailBloc({
    required this.getMasterFileInteractor,
    required this.getProfileInteractor,
    required this.getWeekFoodEventsInteractor,
  }) : super(MacroNutrientsDetailState(
    isLoading: false,
  ),) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.food ||
          category == DataChangedCategory.liquid) {
        add(InitializeEventAction());
      }
    });
    on<InitializeEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      final a = await getProfileInteractor.execute();
      state.userProfile = a;
      state.userProfile?.kcal = getUserKcalSelectiveObjectives(state.userProfile?.kcal ?? 0);
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();

      state.macronutrientsWeekly = ['proteinLabel', 'carbsAvailable', 'fatTotal']
          .map(
            (macronutrient) => NutrientsWeeklyModel(
            nutrientInfoMaster: getNutrientInfo(macronutrient),
            weeklyData: getWeeklyMacroNutrientsDataFormatted(state.weeklyFoodEvents ?? [], macronutrient),
              rda: getMacroNutrientRda(macronutrient),
              upperLimit: getMacroNutrientRda(macronutrient),
            ),
      )
          .toList();

      emit(state.copyWith(isLoading: false));
    },);

    on<LoadMacroNutrientsEventAction>((event, emit) {
      state.macronutrients = event.macronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  NutrientInfoMaster getNutrientInfo(String nutrientName) {
    NutrientInfoMaster nutrientInfo =
        NutrientInfoMaster(officialName: nutrientName, unit: '', en: '', es: '');
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrientName) {
        nutrientInfo = info;
      }
    }
    return nutrientInfo;
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
      var tEE = state.userProfile?.kcal ?? 0;
      if (state.userProfile?.objectives?.contains(50) ?? false) {
        tEE = tEE + tEE ~/ 100 * 15;
      }
      if (state.userProfile?.objectives?.contains(51) ?? false) {
        tEE = tEE - tEE ~/ 100 * 20;
      }
      int kcalPerNutrient = tEE ~/ 100 * getPercentageByMacro(macronutrient);
      int gramsPerNutrient = kcalPerNutrient ~/ getKcalPerGram(macronutrient);
      double nutrientConsumedFraction = (nutrientConsumed / gramsPerNutrient).clamp(0.0, 1.0);
      weeklyData.add({'day': eventWeekDay, 'nutrientConsumed': nutrientConsumed, 'nutrientConsumedFraction': nutrientConsumedFraction});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  int getPercentageByMacro(String macro) {
    var macroo = 0;
    if ((state.userProfile?.objectives?.contains(50) ?? false) || (state.userProfile?.objectives?.contains(51) ?? false)) {
      macroo = macro == 'carbsAvailable' ? 40 : 30;
    }
    else if (state.userProfile?.objectives?.contains(52) ?? false) {
      macroo = macro == 'carbsAvailable' ? 50 : macro == 'proteinLabel' ? 20 : 30;
    }
    else {
      macroo = macro == 'carbsAvailable' ? 30 : 35;
    }
    return macroo;
  }

  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;

  num getMacroNutrientRda(String macronutrient) {
    double kcalPerNutrient = (state.userProfile?.kcal ?? 0) / 100 * getPercentageByMacro(macronutrient);
    double gramsPerNutrient = kcalPerNutrient / getKcalPerGram(macronutrient);
    return gramsPerNutrient.toInt();
  }

  int getUserKcalSelectiveObjectives(int userKcal) {
    int changedKcal = userKcal;

    if (state.userProfile?.objectives?.contains(50) ?? false) {
      changedKcal = changedKcal + changedKcal~/100*15;
    }
    if (state.userProfile?.objectives?.contains(51) ?? false) {
      changedKcal = changedKcal - changedKcal~/100*20;
    }

    return changedKcal;
  }

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}
