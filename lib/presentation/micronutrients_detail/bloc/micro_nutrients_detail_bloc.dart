import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/interactor/profile/get_user_rdas_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

import '../../../infrastructure/utils/constants.dart';

part 'micro_nutrients_detail_event.dart';
part 'micro_nutrients_detail_state.dart';

class MicroNutrientsDetailBloc extends Bloc<MicroNutrientsDetailEvent, MicroNutrientsDetailState> {
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetProfileInteractor getProfileInteractor;

  MicroNutrientsDetailBloc({
    required this.getWeekFoodEventsInteractor,
    required this.getMasterFileInteractor,
    required this.getProfileInteractor,
  }) : super(MicroNutrientsDetailState(
    isLoading: false,
  ),
  ) {

    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final a = await getWeekFoodEventsInteractor.execute();
      state.weeklyFoodEvents = a;
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.profile = await getProfileInteractor.execute();

      state.micronutrientsWeekly = state.profile?.micronutrients.orEmpty()
          .map(
              (micronutrient) => getDataByWeekly(micronutrient),
      ).toList();

      emit(state.copyWith(isLoading: false));
    },);

    on<LoadMicroNutrientsDetails>((event, emit) {
      state.microNutrients = event.micronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  NutrientInfoMaster getNutrientInfo(String nutrientName) {
    NutrientInfoMaster nutrientInfo = NutrientInfoMaster(officialName: nutrientName, unit: '', en: '', es: '');
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrientName) {
        nutrientInfo = info;
      }
    }
    return nutrientInfo;
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

  getNutrientUpperLimit(String micronutrient) {
    num upperLimit = 0.0;
    loop:for (UserRda userRda in state.profile?.userRdas?.userRdas ?? []) {
      if (userRda.name == micronutrient) {
        upperLimit = userRda.upperLimit ?? 0.0;
        // if (userRda.name == Constants.VITAMIN_C && state.profile?.objectives?.contains(Constants.IMPROVE_SPORT_PERFORMANCE) == true) {
        //   upperLimit = (state.profile?.sex == SexType.male) ? 220: 190;
        // }
        // if (userRda.name == Constants.TRYPTOPHAN) {
        //   upperLimit = (state.profile?.physicalCharacteristics?.weight ?? 0) * Constants.TRYPTOPHAN_MG_PER_KG;
        // }
        break loop;
      }
    }
    return upperLimit;
  }

  NutrientsWeeklyModel getDataByWeekly(String micronutrient) {
    final rda = getNutrientRda(micronutrient);

    //WeeklyData
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in state.weeklyFoodEvents ?? []) {
      int weekDay =
          DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <FoodEventComplete>[];
      for (var event in state.weeklyFoodEvents ?? []) {
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
      final nutrientConsumedFraction = (nutrientConsumed / rda).clamp(0.0, 1.0);
      weeklyData
          .add({'day': eventWeekDay, 'nutrientConsumed': nutrientConsumed, 'nutrientConsumedFraction': nutrientConsumedFraction});
    }
    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));

    return NutrientsWeeklyModel(
      nutrientInfoMaster: getNutrientInfo(micronutrient),
      weeklyData: weeklyData,
      rda: rda,
      upperLimit: getNutrientUpperLimit(micronutrient),
    );
  }
}
