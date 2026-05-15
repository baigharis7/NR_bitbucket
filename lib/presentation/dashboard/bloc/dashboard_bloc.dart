import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/fcm/fcm_api.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/update_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/save_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/modelsappearance/show_model_appearance_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/modelsappearance/models_appearance_refs.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/advices/get_advice_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_dashboard_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
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
import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_day_calories_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_today_step_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/save_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/sugar_&_fiber_model.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/lists/SupplementInfo.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/profile/model/user_profile_response.dart';
import '../../../data/local/models/modelsappearence/models_appearance_entity.dart';
import '../../../domain/interactor/eventssync/synchronize_events_interactor.dart';
import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import '../../../domain/interactor/localstorage/erase_db_local_events_interactor.dart';
import '../../../domain/interactor/login/erase_database_interactor.dart';
import '../../../domain/interactor/masterfiles/get_master_file_version_interactor.dart';
import '../../../domain/interactor/masterfiles/manage_master_files_interactor.dart';
import '../../../domain/interactor/profile/sign_out_interactor.dart';
import '../../../domain/interactor/sportevents/get_week_sports_interactor.dart';
import '../../../domain/interactor/supplements/get_today_creatine_event_interactor.dart';
import '../../../domain/interactor/supplements/save_creatine_event_interactor.dart';
import '../../../domain/interactor/waterevents/save_water_event_interactor.dart';
import '../../../domain/interactor/waterevents/upload_water_event_interactor.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/watervents/water_event_master.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:path_provider/path_provider.dart';

class DashboardBloc extends BaseBloc<DashboardActions, DashboardState> {
  final EventsHelper _eventsHelper = EventsHelper();
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;
  DateTime? _lastSelectedDate;
  final GetFoodEventsOfTodayInteractor getFoodEventsOfTodayInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetAdviceInteractor getAdviceInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetDayCaloriesInteractor getDayCaloriesInteractor;
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final UploadProfileInteractor uploadProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final UploadWaterEventInteractor uploadWaterEventInteractor;
  final SaveWaterEventInteractor saveWaterEventInteractor;
  final UploadStepsInteractor uploadStepsInteractor;
  final SaveStepsInteractor saveStepsInteractor;
  final GetStepsInteractor getStepsInteractor;
  final GetTodayStepInteractor getTodayStepInteractor;
  final GetAllEventsSortedByDateInteractor getAllEventsSortedByDateInteractor;
  final GetTodayCreatineEventInteractor getTodayCreatineEventInteractor;
  final UploadCreatineEventInteractor uploadCreatineEventInteractor;
  final SaveCreatineEventInteractor saveCreatineEventInteractor;
  final GetTodayCollagenEventInteractor getTodayCollagenEventInteractor;
  final UploadCollagenEventInteractor uploadCollagenEventInteractor;
  final SaveCollagenEventInteractor saveCollagenEventInteractor;
  final GetAllDashboardEventsSortedByDateInteractor getAllDashboardEventsSortedByDateInteractor;
  final GetMasterFileVersionInteractor getMasterFilesVersionInteractor;
  final ManageMasterFilesInteractor manageMasterFilesInteractor;
  final SignOutInteractor signOutInteractor;
  final EraseDatabaseInteractor eraseDatabaseInteractor;
  final SharedPreferences sharedPreferences;
  final GetRoutinesInteractor getRoutinesInteractor;
  final EraseDBLocalEventsInteractor eraseDBLocalEventsInteractor;
  final SynchronizeEventsInteractor synchronizeEventsInteractor;
  final UpdateEventsInteractor updateEventsInteractor;
  final Chuck chuck;
  final ShowModelAppearanceInteractor showModelAppearanceInteractor;
  final SaveModelAppearanceInteractor saveModelAppearanceInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final GetDaySupplementEventsInteractor getDaySupplementEventsInteractor;
  final FcmApi? fcmApi;

  DashboardBloc({
    required this.getFoodEventsOfTodayInteractor,
    required this.getMasterFileInteractor,
    required this.getAdviceInteractor,
    required this.getUserIdInteractor,
    required this.getProfileInteractor,
    required this.getWaterEventsTodayInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getDayCaloriesInteractor,
    required this.getLiquidEventsOfTodayInteractor,
    required this.getWeekFoodEventsInteractor,
    required this.getWeekLiquidEventsInteractor,
    required this.getWeekSportsInteractor,
    required this.uploadProfileInteractor,
    required this.saveProfileInteractor,
    required this.uploadWaterEventInteractor,
    required this.saveWaterEventInteractor,
    required this.uploadStepsInteractor,
    required this.saveStepsInteractor,
    required this.getStepsInteractor,
    required this.getTodayStepInteractor,
    required this.getAllEventsSortedByDateInteractor,
    required this.getTodayCreatineEventInteractor,
    required this.uploadCreatineEventInteractor,
    required this.saveCreatineEventInteractor,
    required this.getTodayCollagenEventInteractor,
    required this.uploadCollagenEventInteractor,
    required this.saveCollagenEventInteractor,
    required this.getAllDashboardEventsSortedByDateInteractor,
    required this.getMasterFilesVersionInteractor,
    required this.manageMasterFilesInteractor,
    required this.sharedPreferences,
    required this.eraseDatabaseInteractor,
    required this.signOutInteractor,
    required this.getRoutinesInteractor,
    required this.eraseDBLocalEventsInteractor,
    required this.synchronizeEventsInteractor,
    required this.updateEventsInteractor,
    required this.chuck,
    required this.showModelAppearanceInteractor,
    required this.saveModelAppearanceInteractor,
    required this.getTodaySportsInteractor,
    required this.getDaySupplementEventsInteractor,
    this.fcmApi,
  }) : super(DashboardState(
    isLoading: true,
    advice: '',
    waterEvents: [],
    foodEvents: [],
    micronutrients: [],
    macronutrients: [],
    userKcal: 0,
    showCard: false,
    isMenstruation: false,
    energyModel: EnergyModel(fractionToFill: 0.0, totalKcal: 0, rawKcalTaken: 0, spentKcal: 0),
    foundedRoutineRemainingHours: null,
    lastTap: null,
  ),) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      add(RefreshCategoryAction(category: category));
    });

    on<RefreshCategoryAction>((event, emit) async {
      try {
        switch (event.category) {
          case DataChangedCategory.food:
            state.foodEvents = await getFoodEventsOfTodayInteractor.execute(dateTime: _lastSelectedDate);
            state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
            final caloriesConsumed = await getDayCaloriesInteractor.execute(dateTime: _lastSelectedDate);
            state.allCalendarEvents = await getAllDashboardEventsSortedByDateInteractor.execute();
            _recomputeNutrients();
            _recomputeEnergyModel(caloriesConsumed.orZero());
            _recomputeSugarFiber();
            break;
          case DataChangedCategory.water:
            state.waterEvents = await getWaterEventsTodayInteractor.execute(dateTime: _lastSelectedDate);
            break;
          case DataChangedCategory.liquid:
            state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute(dateTime: _lastSelectedDate);
            state.weeklyLiquidEvents = await getWeekLiquidEventsInteractor.execute();
            break;
          case DataChangedCategory.sport:
            state.weeklySportEvents = await getWeekSportsInteractor.execute();
            state.sportEvents = await getTodaySportsInteractor.execute(dateTime: _lastSelectedDate);
            final caloriesConsumed = await getDayCaloriesInteractor.execute(dateTime: _lastSelectedDate);
            state.allCalendarEvents = await getAllDashboardEventsSortedByDateInteractor.execute();
            _recomputeEnergyModel(caloriesConsumed.orZero());
            break;
          case DataChangedCategory.supplement:
            state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: _lastSelectedDate);
            _recomputeNutrients();
            break;
          case DataChangedCategory.fecesUrine:
            state.allCalendarEvents = await getAllDashboardEventsSortedByDateInteractor.execute();
            break;
          case DataChangedCategory.profile:
            state.profile = await getProfileInteractor.execute();
            if (state.profile?.physicalCharacteristics?.unit == 2) {
              state.profile?.physicalCharacteristics?.weight = (state.profile?.physicalCharacteristics?.weight ?? 0) / 2.20462;
            }
            state.userKcal = getUserKcalSelectiveObjectives(state.profile?.kcal ?? 0);
            state.isMenstruation = state.profile?.objectives?.contains(Constants.DURING_MENSTRUATION);
            state.isCold = state.profile?.objectives?.contains(Constants.COLD);
            final caloriesConsumed = await getDayCaloriesInteractor.execute(dateTime: _lastSelectedDate);
            _recomputeNutrients();
            _recomputeEnergyModel(caloriesConsumed.orZero());
            _recomputeSugarFiber();
            break;
          case DataChangedCategory.steps:
            state.todayStep = await getTodayStepInteractor.execute();
            break;
        }
        emit(state.copyWith(isLoading: false, onError: null));
      } catch (error) {
        // Silently handle — dashboard will refresh on next InitializeState
      }
    });

    on<InitializeState>((event, emit) async {
      _lastSelectedDate = event.dateTime;
      // _clearData();
      // emit(state.copyWith(isLoading: true, foundedRoutineRemainingHours: null));
      try {
      // await eraseDBLocalEventsInteractor.execute();
      // await synchronizeEventsInteractor.execute(getUserIdInteractor.execute());
      state.nutrientsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.nutrientsInfo);
      state.objectivesInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.objectivesInfo,);
      state.supplementsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo,);
      state.profile = await getProfileInteractor.execute();
      state.sportInjuryModal = await showModelAppearanceInteractor.execute(ModelsAppearanceRefs.recoveryAfterSportInjury.index);
      if (state.profile?.physicalCharacteristics?.unit == 2) {
        state.profile?.physicalCharacteristics?.weight = (state.profile?.physicalCharacteristics?.weight ?? 0) / 2.20462;
      }
      state.userKcal = getUserKcalSelectiveObjectives(state.profile?.kcal ?? 0);
      state.isMenstruation = state.profile?.objectives?.contains(Constants.DURING_MENSTRUATION);
      state.isCold = state.profile?.objectives?.contains(Constants.COLD);

      final caloriesConsumed = await getDayCaloriesInteractor.execute(dateTime: event.dateTime);
      final todayCreatine = await getTodayCreatineEventInteractor.execute(dateTime: event.dateTime);
      final todayCollagen = await getTodayCollagenEventInteractor.execute(dateTime: event.dateTime);
      var totalSugarRequired = (state.userKcal.orZero()*0.05)~/4;

      state.foodEvents = await getFoodEventsOfTodayInteractor.execute(dateTime: event.dateTime);
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute(dateTime: event.dateTime);
      state.weeklyFoodEvents = await getWeekFoodEventsInteractor.execute();
      state.weeklyLiquidEvents = await getWeekLiquidEventsInteractor.execute();
      state.weeklySportEvents = await getWeekSportsInteractor.execute();
      state.todayStep = await getTodayStepInteractor.execute();
      // state.allCalendarEvents = await getAllEventsSortedByDateInteractor.execute();
      state.waterEvents = await getWaterEventsTodayInteractor.execute(dateTime: event.dateTime);
      state.allCalendarEvents = await getAllDashboardEventsSortedByDateInteractor.execute();
      state.supplementEvents = await getDaySupplementEventsInteractor.execute(dateTime: event.dateTime);
      state.sportEvents = await getTodaySportsInteractor.execute(dateTime: event.dateTime);

      state.micronutrients = state.profile?.micronutrients.orEmpty()
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
            ),
      ).toList();

      state.temporaryMicronutrients = state.profile?.temporaryMicronutrients.orEmpty()
          .map(
            (micronutrient) =>
            NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
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
              rda: getMacroNutrientRda(macronutrient),
              upperLimit: getMacroNutrientRda(macronutrient),
            ),
      ).toList();

      final existingListsOfNutrients = {
        ...state.micronutrients.orEmpty().map((e) => e.nutrientInfoMaster),
        ...state.temporaryMicronutrients.orEmpty().map((e) => e.nutrientInfoMaster),
      };

      final allMicronutrients = state.profile?.userRdas?.userRdas
          .orEmpty()
          .map((nutrient) => NutrientsModel(
        quantityConsumed: getQuantityConsumedSoFar(nutrient.name) + getQuantitySupplementsSoFar(nutrient.name),
        nutrientInfoMaster: getNutrientInfo(nutrient.name),
        fractionToFill: 0.0,
        unit: getUnitForMicronutrient(nutrient.name),
        rda: getNutrientRda(nutrient.name),
        upperLimit: getNutrientUpperLimit(nutrient.name),
      ),).toList();

      state.filteredNutrientsLess15RDA = allMicronutrients.orEmpty().where((nutrient) {
        double percentage = (nutrient.quantityConsumed / nutrient.rda) * 100;
        return percentage <= 15 && nutrient.rda > 0 && !existingListsOfNutrients.contains(nutrient.nutrientInfoMaster);
      }).toList();
      state.filteredNutrientsLess15RDA?.sort((a, b) => b.rda.compareTo(a.rda),);

      state.energyModel = EnergyModel(
        fractionToFill: getFractionToFillKcal(caloriesConsumed.orZero()),
        totalKcal: state.userKcal.orZero(),
        rawKcalTaken: getTotalKcalTakenToday(),
        spentKcal: caloriesConsumed.orZero(),
      );
      state.sugarAndFiberModel = SugarAndFiberModel(
          fractionToFillSugar: calculateTodaySugar(totalSugarRequired),
          totalSugarConsumed: calculateTodayConsumedSugar(totalSugarRequired),
          requiredSugar: totalSugarRequired.toDouble(),
          fractionToFillFiber: calculateTodayFiber(),
          totalFiberConsumed: calculateTodayConsumedFiber(),
        requiredFiber: Constants.FIBER_TOTAL_REQUIRED,
      );

      // final getMasterFileVersionCookingMethods = await getMasterFilesVersionInteractor.execute(MasterFilesType.cookingMethods);
      // final getMasterFileVersionNutrientsInfo = await getMasterFilesVersionInteractor.execute(MasterFilesType.nutrientsInfo);
      // final getMasterFile = await manageMasterFilesInteractor.execute(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
      // state.isUpdatedDataNeeded = getMasterFileVersionCookingMethods != getMasterFile.cookingMethodsResponse?.v || getMasterFileVersionNutrientsInfo != getMasterFile.nutrientsInfoResponse?.v;
      // final routines = await getRoutinesInteractor.execute();
      // state.foundedRoutineRemainingHours = getFoundedRoutineTime(routines);
      }
      catch(error) {
        Fluttertoast.showToast(msg: '$error', toastLength: Toast.LENGTH_LONG, backgroundColor: AppColors.errorRed, textColor: Colors.white);
      }
      _registerFcmToken();
      if (event.onFinish != null) event.onFinish?.call();
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
      // emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateMenstruationStateAction>((event, emit) {
      final menstruationId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.MENSTRUATION).id ?? -1;
      if (menstruationId != -1) {
        manageObjectives(menstruationId);
        add(UpdateProfileEventAction(value: event.isMenstruation));
        state.isMenstruation = event.isMenstruation;
      }

      // emit(state.copyWith(isLoading: false));
    },);

    on<UpdateColdStateAction>((event, emit) {
      // final improveSystemId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.IMPROVE_HUMAN_SYSTEM).id ?? -1;
      const improveSystemId = Constants.COLD;
      if (improveSystemId != -1) {
        manageObjectives(improveSystemId);
        add(UpdateProfileEventAction(value: event.isCold));
        state.isCold = event.isCold;
      }

      // emit(state.copyWith(isLoading: false));
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
        recommededIds: state.profile?.recommededIds.orEmpty()
      );

      UserProfileResponse userProfileResponse;
      try {
        userProfileResponse = await uploadProfileInteractor.execute(profile);
        if (userProfileResponse.uploadSuccess) {
          profile.micronutrients = userProfileResponse.micronutrients;
          profile.userAll = userProfileResponse.userAll;
          profile.temporaryMicronutrients = userProfileResponse.temporaryMicronutrients;
          profile.temporaryAll = userProfileResponse.temporaryAll;
          profile.userRdas = UserRdas(
            userRdas: userProfileResponse.userRdas.map((userRda) => UserRda(name: userRda.n, rda: userRda.rda, ul: userRda.ul, upperLimit: userRda.upperLimit)).toList(),
          );
          profile.kcal = userProfileResponse.kcal;
          try {
            await saveProfileInteractor.execute(profile);
            add(InitializeState());
            // emit(state.copyWith(isLoading: false, onError: null));
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
      if (state.lastTap != null && DateTime.now().difference(state.lastTap!) < const Duration(milliseconds: 200)) {
        return;
      }
      state.lastTap = DateTime.now();

      emit(state.copyWith(isLoading: false, onError: null,));

      final waterEventMaster = WaterEventMaster(
        getUserIdInteractor.execute(),
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        DateTimeHelper().provideCurrentDate().millisecondsSinceEpoch,
        event.qty,
      );

      try {
        await saveWaterEventInteractor.execute(waterEventMaster);
        state.waterEvents = await getWaterEventsTodayInteractor.execute();
        emit(state.copyWith(isLoading: false, onError: null));
        try {
          await uploadWaterEventInteractor.execute(waterEventMaster);
          // event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          waterEventMaster.qty = (-(waterEventMaster.qty)!);
          await saveWaterEventInteractor.execute(waterEventMaster);
          state.waterEvents = await getWaterEventsTodayInteractor.execute();
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingWaterEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.locallySavingWaterEventError));
      }
    });

    on<UploadCreatineEventAction>((event, emit) async {
      var updatingValue = (event.supplementInfo?.uploadSupplementEvent?.value ?? 0) + event.value;
      if (updatingValue < 0) return;
      emit(state.copyWith(isLoading: true));
      UploadSupplementEvent uploadSupplementCreatineEvent = UploadSupplementEvent(
          userId: getUserIdInteractor.execute(),
          eventId: event.supplementInfo?.uploadSupplementEvent?.eventId ?? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch,
          value: updatingValue,
      );
      try {
        await uploadCreatineEventInteractor.execute(uploadSupplementCreatineEvent);
        try {
          await saveCreatineEventInteractor.execute(uploadSupplementCreatineEvent, !(event.supplementInfo?.uploadSupplementEvent?.eventId.isNull() ?? true));
          // emit(state.copyWith(isLoading: false));
          add(InitializeState());
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveCreatineError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadCreatineError));
      }
    },);

    on<UploadCollagenEventAction>((event, emit) async {
      var updatingValue = (event.supplementInfo?.uploadSupplementEvent?.value ?? 0) + event.value;
      if (updatingValue < 0) return;
      emit(state.copyWith(isLoading: true));
      UploadSupplementEvent uploadSupplementCreatineEvent = UploadSupplementEvent(
          userId: getUserIdInteractor.execute(),
          eventId: event.supplementInfo?.uploadSupplementEvent?.eventId ?? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch,
          value: updatingValue,
      );
      try {
        await uploadCollagenEventInteractor.execute(uploadSupplementCreatineEvent);
        try {
          await saveCollagenEventInteractor.execute(uploadSupplementCreatineEvent, !(event.supplementInfo?.uploadSupplementEvent?.eventId.isNull() ?? true));
          // emit(state.copyWith(isLoading: false));
          add(InitializeState());
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveCollagenError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadCollagenError));
      }
    },);

    on<LogoutFromAppEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true,));
      try {
        final token = FcmService.instance.token;
        if (token != null && fcmApi != null) {
          try { await fcmApi!.unregisterToken(token); } catch (_) {}
        }
        // Fire-and-forget Amplify sign-out — it's a network round-trip
        // (~500ms-2s) and the user's local data is what determines whether
        // the next account's session is clean. Local Hive + prefs clear
        // MUST complete before we navigate so the next account's first
        // dashboard read can't pick up orphaned data.
        signOutInteractor.execute();
        await eraseDatabaseInteractor.execute();
        await sharedPreferences.clear();
        state.isUpdatedDataNeeded = false;
        event.onFinish.call();
        emit(state.copyWith(isLoading: false, onError: null,));
      } catch (errorSignOut) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.signOutError));
      }
    },);

    on<ShowDialogEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true,));
      state.isShowDialog = true;
      emit(state.copyWith(isLoading: false));
    },);

    on<ShowLogs>((event, emit) {
      chuck.showInspector();
    },);

    on<SaveHideModelInfo>((event, emit) async {
      final a = await saveModelAppearanceInteractor.execute(ModelsAppearanceRefs.recoveryAfterSportInjury.index);
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
    final rdaForUser = getNutrientRda(micronutrient);
    double nutrientQuantitySoFar = 0.0;
    for (var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        nutrientQuantitySoFar = nutrientQuantitySoFar + (food.params!.toJson()[micronutrient] ?? 0.0);
      }
    }

    double returnQuantity = (nutrientQuantitySoFar / rdaForUser).clamp(0.0, 1.0);
    if (returnQuantity > 1) returnQuantity = 1;
    if (returnQuantity < 0) returnQuantity = 0;
    return returnQuantity;
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

    // final num = state.userRdas!.firstWhere((rda) => rda.name == micronutrient).rda;
    return rda;
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
        final kcalValue = food.params!.toJson()[kcalName] ?? 0.0;
        kcalQuantitySoFar = kcalQuantitySoFar + kcalValue;
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

  double getQuantitySupplementsSoFar(String micronutrient) {
    double supplementQuantitySoFar = 0.0;
    for (var supplement in state.supplementEvents.orEmpty()) {
      for (var supplementItem in supplement.info.orEmpty()) {
        final supplementInfo = state.supplementsInfoMaster?.data.where((element) => supplementItem.id == element.id).firstOrNull;
        if (supplementInfo?.computerName == micronutrient) {
          supplementQuantitySoFar = supplementQuantitySoFar + supplementItem.amount;
        }
      }
    }

    return double.parse((supplementQuantitySoFar).toStringAsFixed(2));
  }

  double calculateTodaySugar(int totalSugarRequired) {
    double sugarConsumedToday = 0.0;
    for(var foodEvent in state.foodEvents!) {
      for (var food in foodEvent.foodInfo!) {
        if (food.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (food.params?.sugarsTotal ?? 0.0);
        }
      }
    }

    for(var liquidEvent in state.todayLiquidEvents!) {
      for (var liquid in liquidEvent.foodInfo!) {
        if (liquid.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
        }
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
        if (food.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (food.params?.sugarsTotal ?? 0.0);
        }
      }
    }

    for(var liquidEvent in state.todayLiquidEvents!) {
      for (var liquid in liquidEvent.foodInfo!) {
        if (liquid.freeSugar.orEmpty() == Constants.FREE_SUGAR) {
          sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
        }
        // sugarConsumedToday = sugarConsumedToday + (liquid.params?.sugarsTotal ?? 0.0);
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

  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 30 : 35;
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 40 : 30; (For gain Muscle's) - Objectives-50
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 40 : 30; (Lose fat) - Objectives-51
  // int getPercentageByMacro(String macro) => macro == 'carbsAvailable' ? 50 : macro == 'proteinSci' ? 20 : 30; (Maintain Weight) - Objectives-52
  int getKcalPerGram(String macro) => macro == 'fatTotal' ? 9 : 4;

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  void manageObjectives(int objective) {
    state.profile!.objectives ??= [];
    state.profile!.objectives!.contains(objective)
        ? state.profile!.objectives!.remove(objective)
        : state.profile!.objectives!.add(objective);
  }

  int getUserKcalSelectiveObjectives(int userKcal) {
    int changedKcal = userKcal;

    if (state.profile?.objectives?.contains(50) ?? false) {
      changedKcal = changedKcal + changedKcal~/100*15;
    }
    if (state.profile?.objectives?.contains(51) ?? false) {
      changedKcal = changedKcal - changedKcal~/100*20;
    }

    return changedKcal;
  }


  num userRdaforSupplement() {
    num creatine = 0.0;
    creatine = 0.08 * (state.profile?.physicalCharacteristics?.weight ?? 0);
    return double.parse(creatine.toStringAsFixed(2));
  }

  List<dynamic> getEventsForDay(DateTime dateTime) {
    if (state.allCalendarEvents.isNull()) return [];
    return _eventsHelper.foundEventsFromGivenDate(state.allCalendarEvents!, dateTime);
  }

  int getFoundedRoutineTime(List<SportRoutineCompleted> routines) {
    // int remainingHours = -1;
    // routineLoop: for (SportRoutineCompleted routine in routines) {
    //   if (routine.routineTime.orEmpty().isNotEmpty) {
    //     final a = DateTimeHelper.dateTimeFromMilliseconds(int.parse(routine.routineTime ?? '0'));
    //     final currentDateTime = DateTime.now();
    //     if (a?.day == currentDateTime.day && a?.month == currentDateTime.month && a?.year == currentDateTime.year) {
    //       if (a?.hour != null) {
    //         remainingHours = a!.hour - currentDateTime.hour;
    //         if (remainingHours > -1) break routineLoop;
    //       }
    //     }
    //   }
    // }
    return -1;
  }

  void _clearData() {
    state.isUpdatedDataNeeded = null;
    state.foundedRoutineRemainingHours = null;
  }

  bool isNeedToShowModel(ModelsAppearanceEntity? sportInjuryModal) {
    if (sportInjuryModal == null) {
      return true;
    } else {
      if (DateTimeHelper.calculateDifferenceHours(sportInjuryModal.time, DateTime.now().millisecondsSinceEpoch) > 3) {
        return true;
      } else {
        return false;
      }
    }
  }

  void _recomputeNutrients() {
    state.micronutrients = state.profile?.micronutrients.orEmpty()
        .map((micronutrient) => NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
            ))
        .toList();

    state.temporaryMicronutrients = state.profile?.temporaryMicronutrients.orEmpty()
        .map((micronutrient) => NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(micronutrient) + getQuantitySupplementsSoFar(micronutrient),
              nutrientInfoMaster: getNutrientInfo(micronutrient),
              fractionToFill: getFractionToFillMicros(micronutrient),
              unit: getUnitForMicronutrient(micronutrient),
              rda: getNutrientRda(micronutrient),
              upperLimit: getNutrientUpperLimit(micronutrient),
            ))
        .toList();

    state.macronutrients = ['proteinSci', 'carbsAvailable', 'fatTotal']
        .map((macronutrient) => NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(macronutrient),
              nutrientInfoMaster: getNutrientInfo(macronutrient),
              fractionToFill: getFractionToFillMacros(macronutrient),
              unit: getUnitForMicronutrient(macronutrient),
              rda: getMacroNutrientRda(macronutrient),
              upperLimit: getMacroNutrientRda(macronutrient),
            ))
        .toList();

    final existingListsOfNutrients = {
      ...state.micronutrients.orEmpty().map((e) => e.nutrientInfoMaster),
      ...state.temporaryMicronutrients.orEmpty().map((e) => e.nutrientInfoMaster),
    };

    final allMicronutrients = state.profile?.userRdas?.userRdas
        .orEmpty()
        .map((nutrient) => NutrientsModel(
              quantityConsumed: getQuantityConsumedSoFar(nutrient.name) + getQuantitySupplementsSoFar(nutrient.name),
              nutrientInfoMaster: getNutrientInfo(nutrient.name),
              fractionToFill: 0.0,
              unit: getUnitForMicronutrient(nutrient.name),
              rda: getNutrientRda(nutrient.name),
              upperLimit: getNutrientUpperLimit(nutrient.name),
            ))
        .toList();

    state.filteredNutrientsLess15RDA = allMicronutrients.orEmpty().where((nutrient) {
      double percentage = (nutrient.quantityConsumed / nutrient.rda) * 100;
      return percentage <= 15 && nutrient.rda > 0 && !existingListsOfNutrients.contains(nutrient.nutrientInfoMaster);
    }).toList();
    state.filteredNutrientsLess15RDA?.sort((a, b) => b.rda.compareTo(a.rda));
  }

  void _recomputeEnergyModel(int caloriesConsumed) {
    state.energyModel = EnergyModel(
      fractionToFill: getFractionToFillKcal(caloriesConsumed),
      totalKcal: state.userKcal.orZero(),
      rawKcalTaken: getTotalKcalTakenToday(),
      spentKcal: caloriesConsumed,
    );
  }

  void _recomputeSugarFiber() {
    var totalSugarRequired = (state.userKcal.orZero() * 0.05) ~/ 4;
    state.sugarAndFiberModel = SugarAndFiberModel(
      fractionToFillSugar: calculateTodaySugar(totalSugarRequired),
      totalSugarConsumed: calculateTodayConsumedSugar(totalSugarRequired),
      requiredSugar: totalSugarRequired.toDouble(),
      fractionToFillFiber: calculateTodayFiber(),
      totalFiberConsumed: calculateTodayConsumedFiber(),
      requiredFiber: Constants.FIBER_TOTAL_REQUIRED,
    );
  }

  void _registerFcmToken() {
    final userId = getUserIdInteractor.execute();
    final token = FcmService.instance.token;
    if (userId.isNotEmpty && token != null && fcmApi != null) {
      fcmApi!.registerToken(userId, token, Platform.isIOS ? 'ios' : 'android')
          .catchError((_) {});
    }
    FcmService.instance.setOnTokenRefresh((newToken) {
      final uid = getUserIdInteractor.execute();
      if (uid.isNotEmpty && fcmApi != null) {
        fcmApi!.registerToken(uid, newToken, Platform.isIOS ? 'ios' : 'android')
            .catchError((_) {});
      }
    });
  }

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}