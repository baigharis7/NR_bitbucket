import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_micronutrients_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/interactor/profile/get_user_rdas_interactor.dart';
import '../../../domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

import '../../../infrastructure/utils/constants.dart';

part 'micro_nutrients_detail_event.dart';
part 'micro_nutrients_detail_state.dart';

class MicroNutrientsDetailBloc extends Bloc<MicroNutrientsDetailEvent, MicroNutrientsDetailState> {
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetDaySupplementEventsInteractor getDaySupplementEventsInteractor;
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  MicroNutrientsDetailBloc({
    required this.getWeekFoodEventsInteractor,
    required this.getMasterFileInteractor,
    required this.getProfileInteractor,
    required this.getFoodEventsOfTodayInteractor,
    required this.getDaySupplementEventsInteractor,
  }) : super(MicroNutrientsDetailState(
    isLoading: false,
  ),
  ) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.food ||
          category == DataChangedCategory.supplement) {
        add(InitializationEventAction());
      }
    });

    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final a = await getWeekFoodEventsInteractor.execute();
      state.weeklyFoodEvents = a;
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.profile = await getProfileInteractor.execute();
      if (state.profile?.physicalCharacteristics?.unit == 2) {
        state.profile?.physicalCharacteristics?.weight = (state.profile?.physicalCharacteristics?.weight ?? 0) / 2.20462;
      }

      state.foodEvents = await getFoodEventsOfTodayInteractor.execute();
      state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: DateTime.now());
      state.supplementsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);

      state.microNutrients = state.profile?.userAll.orEmpty()
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: 0.0,
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
            ),
      ).toList();

      state.temporaryMicronutrients = state.profile?.temporaryAll.orEmpty()
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: 0.0,
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
            ),
      ).toList();

      state.micronutrientsWeekly = state.profile?.userAll.orEmpty()
          .map(
              (micronutrient) => getDataByWeekly(micronutrient),
      ).toList();

      state.temporaryMicronutrientsWeekly = state.profile?.temporaryAll.orEmpty()
          .map(
            (micronutrient) => getDataByWeekly(micronutrient),
      ).toList();

      state.allMicronutrients = state.profile?.userRdas?.userRdas
          .orEmpty()
          .map((nutrient) => NutrientsModel(
        quantityConsumed: getQuantityConsumedSoFar(nutrient.name) + getQuantitySupplementsSoFar(nutrient.name),
        nutrientInfoMaster: getNutrientInfo(nutrient.name),
        fractionToFill: 0.0,
        unit: getUnitForMicronutrient(nutrient.name),
        rda: getNutrientRda(nutrient.name),
        upperLimit: getNutrientUpperLimit(nutrient.name),
      ),).toList();

      state.filteredNutrientsLess15RDA = state.allMicronutrients.orEmpty().where((nutrient) {
        double percentage = (nutrient.quantityConsumed / nutrient.rda) * 100;
        return percentage <= 15;
      }).toList();

      state.filteredNutrientsLess15RDAWeekly = state.filteredNutrientsLess15RDA.orEmpty()
          .map(
            (micronutrient) => getDataByWeekly(micronutrient.nutrientInfoMaster.officialName),
      ).toList();

      state.allMicronutrients = state.allMicronutrients = state.allMicronutrients.orEmpty().where((nutrient) {
        double percentage = (nutrient.quantityConsumed / nutrient.rda) * 100;
        return percentage > 15;
      }).toList();

      state.allMicronutrientsWeekly = state.allMicronutrients.orEmpty()
          .map(
            (micronutrient) => getDataByWeekly(micronutrient.nutrientInfoMaster.officialName),
      ).toList();

      emit(state.copyWith(isLoading: false));
    },);

    on<LoadMicroNutrientsDetails>((event, emit) {
      // state.microNutrients = event.micronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

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

  /// Sum supplement contribution toward a given micronutrient. Mirrors
  /// DashboardBloc.getQuantitySupplementsSoFar so this detail screen agrees
  /// with the dashboard after a supplement is added.
  double getQuantitySupplementsSoFar(String micronutrient) {
    double supplementQuantitySoFar = 0.0;
    for (var supplement in state.supplementEvents.orEmpty()) {
      for (var supplementItem in supplement.info.orEmpty()) {
        final supplementInfo = state.supplementsInfoMaster?.data
            .where((element) => supplementItem.id == element.id)
            .firstOrNull;
        if (supplementInfo?.computerName == micronutrient) {
          supplementQuantitySoFar = supplementQuantitySoFar + supplementItem.amount;
        }
      }
    }
    return double.parse((supplementQuantitySoFar).toStringAsFixed(2));
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
        if (userRda.name == Constants.VITAMIN_C && state.profile?.objectives?.contains(Constants.IMPROVE_SPORT_PERFORMANCE) == true) {
          rda = (state.profile?.sex == SexType.male) ? 220: 190;
        }
        if (userRda.name == Constants.TRYPTOPHAN) {
          rda = (state.profile?.physicalCharacteristics?.weight ?? 0) * rda;
        }
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

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}
