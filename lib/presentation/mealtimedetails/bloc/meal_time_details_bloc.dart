import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/delete_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/foodevents/get_food_events_of_today_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/nutrients_info_master.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'meal_time_details_event.dart';
part 'meal_time_details_state.dart';

class MealTimeDetailsBloc extends Bloc<MealTimeDetailsEvent, MealTimeDetailsState> {
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final DeleteFoodEventInteractor deleteFoodEventInteractor;
  final RemoveFoodEventInteractor removeFoodEventInteractor;
  MealTimeDetailsBloc({
    required this.getFoodEventsOfTodayInteractor,
    required this.getProfileInteractor,
    required this.getMasterFileInteractor,
    required this.deleteFoodEventInteractor,
    required this.removeFoodEventInteractor,
}) : super(MealTimeDetailsState(isLoading: false)) {
    on<InitialMealTimeDetailsEventState>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final a = await getFoodEventsOfTodayInteractor.execute(dateTime: event.dateTime);
      state.foodEvents = a;
      state.foodEvents = state.foodEvents.orEmpty().where((foodEvent) => foodEvent.mealType == state.mealTime?.id.orZero()).toList();
      state.profile = await getProfileInteractor.execute();
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      final foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.foodNames = foodNames;
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames.orEmpty().toList() ?? []);

      state.micronutrients = state.profile?.micronutrients.orEmpty()
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

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFoodArgumentsModelEventState>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.mealTime = event.foodArgumentsModel.mealTime;
      state.selectedDateTime = event.foodArgumentsModel.selectedDateTime;
      add(InitialMealTimeDetailsEventState(dateTime: state.selectedDateTime));
      emit(state.copyWith(isLoading: false));
    });

    on<DeleteFoodMealTimeDetailsEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodEventInteractor.execute(event.foodEventComplete.userId.orEmpty(), event.foodEventComplete.eventId!);
        try {
          await removeFoodEventInteractor.execute(event.foodEventComplete);
          add(InitialMealTimeDetailsEventState());
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
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
      if (info.officialName == nutrientName) {
        nutrientInfo = info;
      }
    }
    return nutrientInfo;
  }

  String getUnitForMicronutrient(String micronutrient) {
    var unit = '';
    for (var info in state.nutrientsInfoMaster!.nutrientsInfo) {
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
    double kcalPerNutrient = (state.profile?.kcal ?? 0) / 100 * getPercentageByMacro(macronutrient);
    double gramsPerNutrient = kcalPerNutrient / getKcalPerGram(macronutrient);
    return gramsPerNutrient.toInt();
  }

  int getPercentageByMacro(String macro) {
    var macroo = 0;
    if ((state.profile?.objectives?.contains(50) ?? false) || (state.profile?.objectives?.contains(51) ?? false)) {
      macroo = macro == 'carbsAvailable' ? 40 : 30;
    }
    else if (state.profile?.objectives?.contains(52) ?? false) {
      macroo = macro == 'carbsAvailable' ? 50 : macro == 'proteinSci' ? 20 : 30;
    }
    else {
      macroo = macro == 'carbsAvailable' ? 30 : 35;
    }
    return macroo;
  }

  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;
}
