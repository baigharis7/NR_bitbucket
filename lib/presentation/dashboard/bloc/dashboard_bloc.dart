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
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
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
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';

import '../../../data/api/profile/model/user_profile_response.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import '../../../domain/interactor/sportevents/get_week_sports_interactor.dart';
import '../../../domain/interactor/waterevents/save_water_event_interactor.dart';
import '../../../domain/interactor/waterevents/upload_water_event_interactor.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/watervents/water_event_master.dart';

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
  final UploadProfileInteractor uploadProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final UploadWaterEventInteractor uploadWaterEventInteractor;
  final SaveWaterEventInteractor saveWaterEventInteractor;

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
    required this.uploadProfileInteractor,
    required this.saveProfileInteractor,
    required this.uploadWaterEventInteractor,
    required this.saveWaterEventInteractor,
  }) : super(DashboardState(
    isLoading: false,
    advice: '',
    waterEvents: [],
    foodEvents: [],
    micronutrients: [],
    macronutrients: [],
    userKcal: 0,
    showCard: false,
    isMenstruation: false,
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
      state.objectivesInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.objectivesInfo,);
      state.profile = await getProfileInteractor.execute();
      state.userKcal = getUserKcalSelectiveObjectives(state.profile?.kcal ?? 0);
      state.isMenstruation = state.profile?.objectives?.contains(28);
      state.isCold = state.profile?.objectives?.contains(18);
      state.micronutrients = state.userMicronutrients!
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              // rda: 0.2,
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
              rda: getMacroNutrientRda(macronutrient),
              // rda: 0.3,
            ),
      ).toList();
      final caloriesConsumed = await getDayCaloriesInteractor.execute();
      state.energyModel = EnergyModel(
        fractionToFill: getFractionToFillKcal(caloriesConsumed.orZero()),
        totalKcal: state.userKcal.orZero(),
        rawKcalTaken: getTotalKcalTakenToday(),
        spentKcal: caloriesConsumed.orZero(),
      );
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
      var totalSugarRequired = (state.userKcal.orZero()~/100*5)~/4;
      state.sugarAndFiberModel = SugarAndFiberModel(
          fractionToFillSugar: calculateTodaySugar(totalSugarRequired),
          totalSugarConsumed: calculateTodayConsumedSugar(totalSugarRequired),
          requiredSugar: totalSugarRequired.toDouble(),
          fractionToFillFiber: calculateTodayFiber(),
          totalFiberConsumed: calculateTodayConsumedFiber(),
        requiredFiber: Constants.FIBER_TOTAL_REQUIRED,
      );
      state.weeklyMicronutrients = state.userRdas
          .orEmpty()
          .map((nutrientRda) => NutrientsModel(
          quantityConsumed: getWeeklyConsumedNutrient(nutrientRda),
          nutrientInfoMaster: getNutrientInfo(nutrientRda.name),
          fractionToFill: getWeeklyFractionFill(nutrientRda),
          unit: getUnitForMicronutrient(nutrientRda.name),
          rda: double.parse((nutrientRda.rda * 7).toStringAsFixed(2)),),).toList();
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

    on<UpdateMenstruationStateAction>((event, emit) {
      final menstruationId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.MENSTRUATION).id ?? -1;
      if (menstruationId != -1) {
        manageObjectives(menstruationId);
        add(UpdateProfileEventAction(value: event.isMenstruation));
        state.isMenstruation = event.isMenstruation;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateColdStateAction>((event, emit) {
      final improveSystemId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.IMPROVE_HUMAN_SYSTEM).id ?? -1;
      if (improveSystemId != -1) {
        manageObjectives(improveSystemId);
        add(UpdateProfileEventAction(value: event.isCold));
        state.isCold = event.isCold;
      }

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateProfileEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      FemaleCharacteristics? femaleCharacteristics;
      if (state.profile!.sex == SexType.female) {
        femaleCharacteristics = FemaleCharacteristics(
          menstruation: Menstruation(
            regularity: state.profile!.femaleCharacteristics!.menstruation!.regularity,
            daysOfCycle: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.daysOfCycle,
            lastStartDate: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.lastStartDate,
          ),
        );
      } else {
        femaleCharacteristics = null;
      }

      UserProfileModel profile = UserProfileModel(
        userId: getUserIdInteractor.execute(),
        commonName: state.profile!.commonName.orEmpty(),
        birthDate: state.profile!.birthDate,
        sex: state.profile!.sex,
        occupationActivityFactor: state.profile!.occupationActivityFactor ?? 1.2,
        physicalCharacteristics: PhysicalCharacteristics(
          height: state.profile!.physicalCharacteristics!.height,
          weight: state.profile!.physicalCharacteristics!.weight,
          unit: state.profile?.physicalCharacteristics?.unit,
          bodyFat: state.profile!.physicalCharacteristics!.bodyFat,
          waistMeasurement: state.profile!.physicalCharacteristics!.waistMeasurement,),
        femaleCharacteristics: femaleCharacteristics,
        medicalSituation: MedicalSituation(
          commonDiseases: state.profile!.medicalSituation!.commonDiseases,
          otherDiseases: [], // Añadir a pantalla
          // underPharmaceuticalTreatment: isUnderTreatment,
        ),
        foodAversions: state.profile!.foodAversions,
        dietType: state.profile!.dietType ?? 0,
        exclusions: Exclusions(exclusions: state.profile!.exclusions!.exclusions),
        intolerances: state.profile!.intolerances,
        // symptoms: , // Añadir cuando esté implementado
        guts: 0,
        objectives: state.profile!.objectives,
        feces: state.profile?.feces ?? -1,
        urine: state.profile?.urine ?? -1,
      );

      UserProfileResponse userProfileResponse;
      try {
        userProfileResponse = await uploadProfileInteractor.execute(profile);
        if (userProfileResponse.uploadSuccess) {
          profile.micronutrients = userProfileResponse.micronutrients;
          profile.userRdas = UserRdas(
            userRdas: userProfileResponse.userRdas.map((userRda) => UserRda(name: userRda.n, rda: userRda.rda, ul: userRda.ul)).toList(),
          );
          profile.kcal = userProfileResponse.kcal;
          try {
            await saveProfileInteractor.execute(profile);
            add(InitializeState());
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.savingProfileError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingProfileError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingProfileError));
      }
    });

    on<FinishWaterEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));

      final waterEventMaster = WaterEventMaster(
        getUserIdInteractor.execute(),
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        event.qty,
      );

      try {
        final uploadSuccess = await uploadWaterEventInteractor.execute(waterEventMaster);
        if (uploadSuccess) {
          try {
            saveWaterEventInteractor.execute(waterEventMaster);
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.locallySavingWaterEventError));
          }
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingWaterEventError));
      }
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
    if (returnQuantity < 0) returnQuantity = 0;
    return returnQuantity;
  }

  num getNutrientRda(String micronutrient) {
    num rda = 0.0;
    loop:for (UserRda userRda in state.userRdas ?? []) {
      if (userRda.name == micronutrient) {
        rda = userRda.rda;
        break loop;
      }
    }

    // final num = state.userRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    return rda;
  }

  double getFractionToFillMacros(String macronutrient) {
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar +
            (food.params!.toJson()[macronutrient] ?? 0.0);
      }
    }

    // var tEE = state.userKcal ?? 0;
    // if (state.userObjectives?.contains(50) ?? false) {
    //   tEE = tEE + tEE~/100*15;
    // }
    // if (state.userObjectives?.contains(51) ?? false) {
    //   tEE = tEE - tEE~/100*20;
    // }
    double kcalPerNutrient = (state.userKcal.orZero()/100) * getPercentageByMacro(macronutrient);
    double gramsPerNutrient = kcalPerNutrient / getKcalPerGram(macronutrient);
    double returnQuantity = nutrientQuantitySoFar / gramsPerNutrient;
    if (returnQuantity > 1) returnQuantity = 1;
    return returnQuantity;
  }

  num getMacroNutrientRda(String macronutrient) {
    // num macroRda = 0.0;
    // var tEE = state.userKcal ?? 0;
    // if (state.userObjectives?.contains(50) ?? false) {
    //   tEE = tEE + tEE~/100*15;
    // }
    // if (state.userObjectives?.contains(51) ?? false) {
    //   tEE = tEE - tEE~/100*20;
    // }
    double kcalPerNutrient = state.userKcal.orZero()/100 * getPercentageByMacro(macronutrient);
    double gramsPerNutrient = kcalPerNutrient / getKcalPerGram(macronutrient);
    return gramsPerNutrient.toInt();
  }

  double getFractionToFillKcal(int caloriesConsumed) {
    const kcalName = 'energyKcal';
    double kcalQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        kcalQuantitySoFar = kcalQuantitySoFar + (food.params!.toJson()[kcalName] ?? 0.0);
      }
    }

    // double returnQuantity = (kcalQuantitySoFar.toInt() + getTodayKcalFromLiquids(state.todayLiquidEvents!)) / (state.userKcal! + caloriesConsumed);
    double returnQuantity = ((kcalQuantitySoFar.toInt() + getTodayKcalFromLiquids(state.todayLiquidEvents!)) - caloriesConsumed) / state.userKcal!;
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

  double calculateTodaySugar(int totalSugarRequired) {
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

    sugarConsumedToday = sugarConsumedToday / totalSugarRequired;
    if (sugarConsumedToday > 1) sugarConsumedToday = 1.0;
    if (sugarConsumedToday < 0) sugarConsumedToday = 0.0;
    return double.parse(sugarConsumedToday.toStringAsFixed(2));
  }

  double calculateTodayConsumedSugar(int totalSugarRequired) {
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

    // var tEE = state.userKcal ?? 0;
    // tEE = tEE~/100*5;
    // sugarConsumedToday = (sugarConsumedToday*4)/totalSugarRequired;
    // sugarConsumedToday = sugarConsumedToday/4;
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

    // fiberConsumedToday = fiberConsumedToday/25;
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
    if ((state.userObjectives?.contains(50) ?? false) || (state.userObjectives?.contains(51) ?? false)) {
      macroo = macro == 'carbsAvailable' ? 40 : 30;
    }
    else if(state.userObjectives?.contains(52) ?? false) {
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

  void manageObjectives(int objective) {
    state.profile!.objectives ??= [];
    state.profile!.objectives!.contains(objective)
        ? state.profile!.objectives!.remove(objective)
        : state.profile!.objectives!.add(objective);
  }

  int getUserKcalSelectiveObjectives(int userKcal) {
    int changedKcal = userKcal;

    if (state.userObjectives?.contains(50) ?? false) {
      changedKcal = changedKcal + changedKcal~/100*15;
    }
    if (state.userObjectives?.contains(51) ?? false) {
      changedKcal = changedKcal - changedKcal~/100*20;
    }

    return changedKcal;
  }

}