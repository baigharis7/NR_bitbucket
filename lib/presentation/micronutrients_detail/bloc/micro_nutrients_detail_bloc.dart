import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_user_rdas_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

part 'micro_nutrients_detail_event.dart';
part 'micro_nutrients_detail_state.dart';

class MicroNutrientsDetailBloc extends Bloc<MicroNutrientsDetailEvent, MicroNutrientsDetailState> {
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetUserMicronutrientsInteractor getUserMicronutrientsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserRdasInteractor getUserRdasInteractor;

  MicroNutrientsDetailBloc({
    required this.getWeekFoodEventsInteractor,
    required this.getUserMicronutrientsInteractor,
    required this.getMasterFileInteractor,
    required this.getUserRdasInteractor,
  }) : super(MicroNutrientsDetailState(
    isLoading: false,
  ),
  ) {

    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      state.userMicronutrients = await getUserMicronutrientsInteractor.execute() ?? [];
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.userRdas = await getUserRdasInteractor.execute();

      state.micronutrientsWeekly = state.userMicronutrients!
          .map(
              (micronutrient) => NutrientsWeeklyModel(
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              weeklyData: getWeeklyMicroNutrientsDataFormatted(
                  state.weeklyFoodEvents ?? [], micronutrient))).toList();

      emit(state.copyWith(isLoading: false));
    },);

    on<LoadMicroNutrientsDetails>((event, emit) {
      state.microNutrients = event.micronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

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
}
