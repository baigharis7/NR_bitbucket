import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/sugar_&_fiber_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/lists/SupplementInfo.dart';

import '../../../data/api/steps/models/step_event_response.dart';
import '../../../data/api/supplements/model/upload_supplement_event.dart';
import '../../../data/local/models/modelsappearence/models_appearance_entity.dart';
import '../../../domain/models/calendar/calendar_events.dart';
import '../../../domain/models/calendar/dashboard_all_calendar_events.dart';
import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/masterfiles/objectives_info_master.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class DashboardState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? foodEvents;
  List<LiquidEventComplete>? todayLiquidEvents;
  NutrientsInfoMaster? nutrientsInfoMaster;
  ObjectivesInfoMaster? objectivesInfoMaster;
  UserProfileModel? profile;
  String? advice;
  List<NutrientsModel>? micronutrients;
  List<NutrientsModel>? macronutrients;
  int? userKcal;
  EnergyModel? energyModel;
  List<WaterEventMaster>? waterEvents;
  bool? showCard;
  SugarAndFiberModel? sugarAndFiberModel;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<FoodEventComplete>? weeklyLiquidEvents;
  List<SportEventComplete>? weeklySportEvents;
  bool? isMenstruation;
  bool? isCold;
  StepEventResponse? todayStep;
  List<SupplementInfo>? supplements;
  SupplementInfo? todayCreatineSupplement;
  SupplementInfo? todayCollagenSupplement;
  DashboardAllCalendarEvents? allCalendarEvents;
  bool? isUpdatedDataNeeded;
  int? foundedRoutineRemainingHours;
  bool? isShowDialog;
  ModelsAppearanceEntity? sportInjuryModal;

  DashboardState({
    required this.isLoading,
    this.onError,
    this.foodEvents,
    this.todayLiquidEvents,
    this.nutrientsInfoMaster,
    this.objectivesInfoMaster,
    this.profile,
    this.advice,
    this.micronutrients,
    this.macronutrients,
    this.userKcal,
    this.energyModel,
    this.waterEvents,
    this.showCard,
    this.sugarAndFiberModel,
    this.weeklyFoodEvents,
    this.weeklyLiquidEvents,
    this.weeklySportEvents,
    this.isMenstruation,
    this.isCold,
    this.todayStep,
    this.supplements,
    this.todayCreatineSupplement,
    this.todayCollagenSupplement,
    this.allCalendarEvents,
    this.isUpdatedDataNeeded,
    this.foundedRoutineRemainingHours,
    this.isShowDialog,
    this.sportInjuryModal,
  });

  DashboardState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? foodEvents,
    List<LiquidEventComplete>? todayLiquidEvents,
    bool? infoLoaded,
    NutrientsInfoMaster? nutrientsInfoMaster,
    ObjectivesInfoMaster? objectivesInfoMaster,
    UserProfileModel? profile,
    String? advice,
    List<NutrientsModel>? micronutrients,
    List<NutrientsModel>? macronutrients,
    int? userKcal,
    EnergyModel? energyModel,
    List<WaterEventMaster>? waterEvents,
    bool? showCard,
    SugarAndFiberModel? sugarAndFiberModel,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<FoodEventComplete>? weeklyLiquidEvents,
    List<SportEventComplete>? weeklySportEvents,
    List<NutrientsModel>? weeklyMicronutrients,
    bool? isMenstruation,
    bool? isCold,
    StepEventResponse? todayStep,
    List<SupplementInfo>? supplements,
    SupplementInfo? todayCreatineSupplement,
    SupplementInfo? todayCollagenSupplement,
    DashboardAllCalendarEvents? allCalendarEvents,
    bool? isUpdatedDataNeeded,
    int? foundedRoutineRemainingHours,
    bool? isShowDialog,
    ModelsAppearanceEntity? sportInjuryModal,
  }) {
    return DashboardState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodEvents: foodEvents ?? this.foodEvents,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      objectivesInfoMaster: objectivesInfoMaster ?? this.objectivesInfoMaster,
      profile: profile ?? this.profile,
      advice: advice ?? this.advice,
      micronutrients: micronutrients ?? this.micronutrients,
      macronutrients: macronutrients ?? this.macronutrients,
      userKcal: userKcal ?? this.userKcal,
      energyModel: energyModel ?? this.energyModel,
      waterEvents: waterEvents ?? this.waterEvents,
      showCard: showCard ?? this.showCard,
      sugarAndFiberModel: sugarAndFiberModel ?? this.sugarAndFiberModel,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      weeklyLiquidEvents: weeklyLiquidEvents ?? this.weeklyLiquidEvents,
      weeklySportEvents: weeklySportEvents ?? this.weeklySportEvents,
      isMenstruation: isMenstruation ?? this.isMenstruation,
      isCold: isCold ?? this.isCold,
      todayStep: todayStep ?? this.todayStep,
      supplements: supplements ?? this.supplements,
      todayCreatineSupplement: todayCreatineSupplement ?? this.todayCreatineSupplement,
      todayCollagenSupplement: todayCollagenSupplement ?? this.todayCollagenSupplement,
      allCalendarEvents: allCalendarEvents ?? this.allCalendarEvents,
      isUpdatedDataNeeded: isUpdatedDataNeeded ?? this.isUpdatedDataNeeded,
      foundedRoutineRemainingHours: foundedRoutineRemainingHours ?? this.foundedRoutineRemainingHours,
      isShowDialog: isShowDialog ?? this.isShowDialog,
      sportInjuryModal: sportInjuryModal ?? this.sportInjuryModal,
    );
  }

}