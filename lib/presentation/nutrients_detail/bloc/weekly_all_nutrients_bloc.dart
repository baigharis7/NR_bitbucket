import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/utils/constants.dart';

part 'weekly_all_nutrients_event.dart';
part 'weekly_all_nutrients_state.dart';

class WeeklyAllNutrientsBloc extends Bloc<WeeklyAllNutrientsEventActions, WeeklyAllNutrientsState> {
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;

  WeeklyAllNutrientsBloc({
    required this.getProfileInteractor,
    required this.getMasterFileInteractor,
    required this.getWeekFoodEventsInteractor,
  }) : super(WeeklyAllNutrientsState(isLoading: false,)) {
    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.profile = await getProfileInteractor.execute();
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();

      state.weeklyMicronutrients = state.profile?.userRdas?.userRdas
          .orEmpty()
          .map((nutrient) => getNutrientByWeek(nutrient),).toList();

      emit(state.copyWith(isLoading: false));
    });

  }

  NutrientsModel getNutrientByWeek(UserRda nutrient) {
    final rda = double.parse((getNutrientRda(nutrient.name) * 7).toStringAsFixed(2));

    var nutrientInfo = NutrientInfoMaster(officialName: nutrient.name, unit: '', en: '', es: '');
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrient.name) {
        nutrientInfo = info;
      }
    }

    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.weeklyFoodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[nutrient.name] ?? 0.0);
      }
    }
    nutrientQuantitySoFar = double.parse((nutrientQuantitySoFar).toStringAsFixed(2));

    var weeklyNutrientQuantitySoFar = (nutrientQuantitySoFar/ rda).clamp(0.0, 1.0);

    var unit = '';
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrient.name) {
        unit = info.unit;
      }
    }

    return NutrientsModel(
      nutrientInfoMaster: nutrientInfo,
      quantityConsumed: nutrientQuantitySoFar,
      unit: unit,
      fractionToFill: weeklyNutrientQuantitySoFar,
      upperLimit: getNutrientUpperLimit(nutrient.name) * 7,
      rda: rda,
    );
  }

  num getNutrientUpperLimit(String micronutrient) {
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
}
