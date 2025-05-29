import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/login/erase_database_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/sign_out_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/upload_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/activity_by_occupation_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/allergens.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/common_diseases.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/height_weight_units.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/intolerances.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/model/aversions_ui_model.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_actions.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/utils/constants.dart';


class ProfileBloc extends BaseBloc<ProfileActions, ProfileState> {
  final GetProfileInteractor getProfileInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final UploadProfileInteractor uploadProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final SignOutInteractor signOutInteractor;
  final EraseDatabaseInteractor eraseDatabaseInteractor;
  final SharedPreferences sharedPreferences;

  ProfileBloc({
    required this.getProfileInteractor,
    required this.getMasterFileInteractor,
    required this.getUserIdInteractor,
    required this.uploadProfileInteractor,
    required this.saveProfileInteractor,
    required this.signOutInteractor,
    required this.eraseDatabaseInteractor,
    required this.sharedPreferences,
  }) : super(ProfileState(
    isLoading: false,
    profile: UserProfileModel.empty(),
    foodsAndDrinksNamesMaster: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [],)),
    recommendationGroupsMaster: RecommendationGroupsMaster(recommendationGroups: []),
    objectivesInfoMaster: ObjectivesInfoMaster(objectives: [], metabolicObjectives: [], bodyCompositionObjectives: []),
    showVegetarianDiets: false,
    aversionsUI: AversionsUIModel(foodGroups: []),
    activityTypes: [],
  ),) {
    on<InitializeStateFromProfileAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));
      state.profile = await getProfileInteractor.execute();
      state.objectivesInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.objectivesInfo,);
      state.objectivesFilteredList = state.objectivesInfoMaster?.objectives.where((element) => element.id != Constants.DURING_MENSTRUATION).toList();
      state.foodsAndDrinksNamesMaster = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames,);
      state.recommendationGroupsMaster = await getMasterFileInteractor.execute(MasterFilesType.recommendationGroups);
      if (event.context != null) state.aversionsUI = populateAversions(event.context!);
      state.allergens = Allergens.listAllAllergens();
      state.dietTypes = DietType.listInitialDietTypes();
      state.intolerances = Intolerances.listAllIntolerances();
      state.commonDiseases = CommonDiseases.listAllDiseases();
      state.activityTypes = ActivityByOccupationType.listAllActivityTypes();
      final combineList = (state.objectivesInfoMaster?.objectives ?? []) + (state.objectivesInfoMaster?.metabolicObjectives ?? []) + (state.objectivesInfoMaster?.bodyCompositionObjectives ?? []);
      state.filteredObjectives = getObjectives(combineList);
      state.isMenstruation = state.profile?.objectives?.contains(Constants.DURING_MENSTRUATION);
      state.isCold = state.profile?.objectives?.contains(Constants.COLD);
      state.unitWeightHeight = HeightWeightUnits.getAllUnits().firstWhere((element) => element.id == state.profile?.physicalCharacteristics?.unit, orElse: () => HeightWeightUnits());
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<InitializeStateFromRegistryAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      state.objectivesInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.objectivesInfo,);
      state.objectivesFilteredList = state.objectivesInfoMaster?.objectives.where((element) => element.id != Constants.DURING_MENSTRUATION).toList();
      state.foodsAndDrinksNamesMaster = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames,);
      state.recommendationGroupsMaster = await getMasterFileInteractor.execute(MasterFilesType.recommendationGroups);
      state.aversionsUI = populateAversions(event.context);
      state.allergens = Allergens.listAllAllergens();
      state.dietTypes = DietType.listInitialDietTypes();
      state.intolerances = Intolerances.listAllIntolerances();
      state.commonDiseases = CommonDiseases.listAllDiseases();
      state.activityTypes = ActivityByOccupationType.listAllActivityTypes();
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<AddObjectiveToListAction>((event, emit) {
      manageObjectives(event.id);
      emit(state.copyWith(isLoading: false, onError: null,),);
    });

    on<AddRadioObjectiveToListAction>((event, emit) {
      state.profile!.objectives ??= [];
      if (event.id != 50) if (state.profile!.objectives!.contains(50)) state.profile!.objectives!.remove(50);
      if (event.id != 51) if (state.profile!.objectives!.contains(51)) state.profile!.objectives!.remove(51);
      if (event.id != 52) if (state.profile!.objectives!.contains(52)) state.profile!.objectives!.remove(52);
      manageObjectives(event.id);
      emit(state.copyWith(isLoading: false, onError: null,),);
    });

    on<RefreshCommonNameAction>((event, emit) {
      state.profile!.commonName = event.commonName.orEmpty();
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<RefreshBirthdateAction>((event, emit) {
      state.profile!.birthDate = event.birthdate;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetBodyParameterAction>((event, emit) {
      manageBodyParameters(event);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetSexAction>((event, emit) {
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
      state.profile!.sex = event.sex;
      if (state.profile!.sex == SexType.female) {
        state.isFemale = true;
        state.profile!.femaleCharacteristics = FemaleCharacteristics(menstruation: Menstruation());
      }
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetDietQuestionsCheckedAction>((event, emit) {
      state.areDietQuestionsChecked = true;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
        areDietQuestionsChecked: true,
      ),);
    });

    on<SetDietTypeAction>((event, emit) {
      state.profile!.dietType = event.dietType;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<AddAllergenAction>((event, emit) {
      manageAllergens(event.allergenId);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<AddIntolerancesAction>((event, emit) {
      manageIntolerances(event.intoleranceId);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<ManageAversionsAction>((event, emit) {
      manageAversion(event.foodId);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<RemoveAversionAction>((event, emit) {
      removeAversion(event.foodId);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<ManageCommonDiseaseAction>((event, emit) {
      manageCommonDiseases(event.commonDiseaseId);
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<AddOtherDiseaseAction>((event, emit) {
      state.profile!.medicalSituation ??= MedicalSituation();
      state.profile!.medicalSituation!.otherDiseases =
          event.otherDisease.split(',')
              .map((disease) => disease.trim())
              .toList();
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetPeriodRegularityAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null),);
      // state.profile!.femaleCharacteristics ??= FemaleCharacteristics(menstruation: Menstruation());
      state.profile!.femaleCharacteristics!.menstruation!.regularity =
          event.periodRegularity;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetPeriodDurationAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null),);
      state.profile!.femaleCharacteristics!.menstruation!.daysOfCycle = event.days;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetLastPeriodDateAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null),);
      state.profile!.femaleCharacteristics!.menstruation!.lastStartDate =
          event.date.millisecondsSinceEpoch;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<SetActivityTypeAction>((event, emit) {
      state.profile!.occupationActivityFactor = event.activityType;
      emit(state.copyWith(
        isLoading: false,
        onError: null,
      ),);
    });

    on<AddVegetarianDietsOptions>((event, emit) {
      state.showVegetarianDiets = event.showVegetarianDiets;
      state.dietTypes = DietType.listAllDietsButVegetarian();
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<StopShowingVegetarianDiets>((event, emit) {
      state.showVegetarianDiets = false;
      state.dietTypes = DietType.listInitialDietTypes();
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SaveChangesAction>((event, emit) async {
      if ((state.profile?.physicalCharacteristics?.height ?? 0) <= 0 || (state.profile?.physicalCharacteristics?.weight ?? 0) <= 0) return;
      emit(state.copyWith(isLoading: true, onError: null));
      FemaleCharacteristics? femaleCharacteristics;
      if (state.profile!.sex == SexType.female) {
        femaleCharacteristics = FemaleCharacteristics(
          menstruation: Menstruation(
            regularity: state.profile?.femaleCharacteristics?.menstruation?.regularity ?? Constants.PERIOD_DURATION_INITIAL_VALUE,
            // TODO: estos dos pueden ir a null si regularity es irregular.
            daysOfCycle: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile?.femaleCharacteristics?.menstruation?.daysOfCycle ?? Constants.PERIOD_DURATION_INITIAL_VALUE,
            lastStartDate: state.profile!.femaleCharacteristics!.menstruation!.regularity == MenstruationRegularity.irregular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.lastStartDate,),);
      } else {
        femaleCharacteristics = null;
      }

      UserProfileModel profile = UserProfileModel(
        userId: getUserIdInteractor.execute(),
        commonName: state.profile!.commonName.orEmpty(),
        birthDate: state.profile!.birthDate,
        sex: state.profile!.sex,
        occupationActivityFactor: state.profile!.occupationActivityFactor,
        physicalCharacteristics: PhysicalCharacteristics(
          height: state.profile!.physicalCharacteristics!.height,
          weight: state.profile!.physicalCharacteristics!.weight,
          unit: state.profile!.physicalCharacteristics?.unit ?? 1,
          bodyFat: state.profile!.physicalCharacteristics!.bodyFat,
          waistMeasurement: state.profile!.physicalCharacteristics!.waistMeasurement,),
        femaleCharacteristics: femaleCharacteristics,
        medicalSituation: MedicalSituation(
          commonDiseases: state.profile!.medicalSituation!.commonDiseases,
          otherDiseases: [], // Añadir a pantalla
          // underPharmaceuticalTreatment: isUnderTreatment,
        ),
        foodAversions: state.profile!.foodAversions,
        dietType: state.profile!.dietType == null || state.profile!.dietType! <= 0 ? -1 : state.profile!.dietType,
        exclusions: Exclusions(exclusions: state.profile!.exclusions!.exclusions),
        intolerances: state.profile!.intolerances,
        // symptoms: , // Añadir cuando esté implementado
        guts: 0,
        objectives: state.profile!.objectives,
        micronutrients: state.profile!.micronutrients,
        userRdas: state.profile!.userRdas,
        recommededIds: state.profile?.recommededIds.orEmpty(),
        kcal: state.profile!.kcal,
      );

      UserProfileResponse userProfileResponse;
      try {
        userProfileResponse = await uploadProfileInteractor.execute(profile);
        if (userProfileResponse.uploadSuccess) {
          profile.micronutrients = userProfileResponse.micronutrients;
          profile.userRdas = UserRdas(
            userRdas: userProfileResponse.userRdas.map((userRda) => UserRda(name: userRda.n, rda: userRda.rda, ul: userRda.ul, upperLimit: userRda.upperLimit)).toList(),
          );
          profile.kcal = userProfileResponse.kcal;
          try {
            await saveProfileInteractor.execute(profile);
            add(InitializeStateFromProfileAction(context: null));
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

    on<FinishProfileAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      FemaleCharacteristics? femaleCharacteristics;
      if (state.profile!.sex == SexType.female) {
        femaleCharacteristics = FemaleCharacteristics(
          menstruation: Menstruation(
            regularity: state.profile?.femaleCharacteristics?.menstruation?.regularity ?? Constants.PERIOD_DURATION_INITIAL_VALUE,
            daysOfCycle: state.profile!.femaleCharacteristics!.menstruation!.regularity != MenstruationRegularity.regular.index ? null : state.profile?.femaleCharacteristics?.menstruation?.daysOfCycle ?? Constants.PERIOD_DURATION_INITIAL_VALUE,
            lastStartDate: state.profile!.femaleCharacteristics!.menstruation!.regularity != MenstruationRegularity.regular.index ? null : state.profile!.femaleCharacteristics!.menstruation!.lastStartDate,
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
          unit: state.profile?.physicalCharacteristics?.unit ?? 1,
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
        recommededIds: state.profile?.recommededIds.orEmpty(),
      );

      UserProfileResponse userProfileResponse;
      try {
        userProfileResponse = await uploadProfileInteractor.execute(profile);
        if (userProfileResponse.uploadSuccess) {
          profile.micronutrients = userProfileResponse.micronutrients;
          profile.userRdas = UserRdas(
            userRdas: userProfileResponse.userRdas.map((userRda) => UserRda(name: userRda.n, rda: userRda.rda, ul: userRda.ul, upperLimit: userRda.upperLimit)).toList(),
          );
          profile.kcal = userProfileResponse.kcal;
          try {
            await saveProfileInteractor.execute(profile);
            event.nextScreen.call();
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

    on<PerformLogOutAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, ));
      try {
        signOutInteractor.execute();
        event.goToLogin.call();
        eraseDatabaseInteractor.execute();
        sharedPreferences.clear();
        emit(state.copyWith(isLoading: false, onError: null, ));
      } catch (errorSignOut) {
        state.onError = ErrorTypes.signOutError;
        emit(state.copyWith(isLoading: false, onError: null, ));
      }
    });

    on<SetMenstruationStateAction>((event, emit) {
      final mens = event.isMenstruation;
      final menstruationId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.MENSTRUATION).id ?? -1;
      if (menstruationId != -1) {
        manageObjectives(menstruationId);
        add(FinishProfileAction(nextScreen: event.onFinish));
        state.isMenstruation = event.isMenstruation;
      }

      // emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<SetColdStateAction>((event, emit) {
      // final improveSystemId = state.objectivesInfoMaster?.objectives.firstWhere((objective) => objective.en == Constants.IMPROVE_HUMAN_SYSTEM).id ?? -1;
      const improveSystemId = Constants.COLD;
      if (improveSystemId != -1) {
        manageObjectives(improveSystemId);
        add(FinishProfileAction(nextScreen: event.onFinish));
        state.isCold = event.isCold;
      }

      // emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<SetUnitWeightHeight>((event, emit) {
      state.unitWeightHeight = event.unitWeightHeight;
      state.profile?.physicalCharacteristics?.unit = event.unitWeightHeight?.id;

      emit(state.copyWith(isLoading: false, onError: null));
    },);
  }

  void manageObjectives(int objective) {
    state.profile!.objectives ??= [];
    state.profile!.objectives!.contains(objective)
        ? state.profile!.objectives!.remove(objective)
        : state.profile!.objectives!.add(objective);
  }

  void manageAllergens(int allergen) {
    state.profile!.exclusions ??= Exclusions();
    state.profile!.exclusions!.exclusions ??= [];
    state.profile!.exclusions!.exclusions!.contains(allergen)
        ? state.profile!.exclusions!.exclusions!.remove(allergen)
        : state.profile!.exclusions!.exclusions!.add(allergen);
  }

  void manageIntolerances(int intolerance) {
    state.profile!.intolerances ??= [];
    state.profile!.intolerances!.contains(intolerance)
        ? state.profile!.intolerances!.remove(intolerance)
        : state.profile!.intolerances!.add(intolerance);
  }

  void manageBodyParameters(SetBodyParameterAction event) {
    switch (event.type) {
      case BodyParameters.height:
        state.profile!.physicalCharacteristics?.height = double.parse(event.parameter.toStringAsFixed(2));
        break;
      case BodyParameters.weight:
        state.profile!.physicalCharacteristics?.weight = double.parse(event.parameter.toStringAsFixed(2));
        break;
      case BodyParameters.bodyFat:
        state.profile!.physicalCharacteristics?.bodyFat = event.parameter.toInt();
        break;
      case BodyParameters.waist:
        state.profile!.physicalCharacteristics?.waistMeasurement = event.parameter.toInt();
        break;
    }
  }

  void manageAversion(int aversionId) {
    state.profile!.foodAversions ??= [];
    state.profile!.foodAversions!.contains(aversionId)
        ? state.profile!.foodAversions!.remove(aversionId)
        : state.profile!.foodAversions!.add(aversionId);
  }

  void removeAversion(int aversionId) {
    state.profile!.foodAversions ??= [];
    state.profile!.foodAversions!.remove(aversionId);
  }

  void manageCommonDiseases(int commonDiseaseId) {
    state.profile!.medicalSituation!.commonDiseases!.contains(commonDiseaseId)
        ? state.profile!.medicalSituation!.commonDiseases!.remove(commonDiseaseId)
        : state.profile!.medicalSituation!.commonDiseases!.add(commonDiseaseId);
  }

  double getPhysicalCharacteristicsFillPercentage() {
    int variables = 5;
    int totalVariables = 7;
    if (_isWaistMeasurementFilled()) variables += 1;
    if (_isBodyFatFilled()) variables += 1;
    return _calculatePercentage(variables, totalVariables);
  }

  double getMedicalSituationFillPercentage() {
    if (_isMedicalSituationFilled()) {
      return 1.0;
    } else {
      return 0;
    }
  }

  double getDietPercentageFill() {
    int variablesSum = 0;
    if (getDietTypeFillPercentage() != 0) variablesSum +=1;
    if (getAllergiesFillPercentage() != 0) variablesSum +=1;
    if (getIntolerancesFillPercentage() != 0) variablesSum +=1;
    if (getAversionsFillPercentage() != 0) variablesSum +=1;
    return _calculatePercentage(variablesSum, 1).clamp(0.0, 1.0);
  }

  double getDietTypeFillPercentage() {
    if (_isDietTypeFilled()) {
      return 1;
    } else {
      return 0;
    }
  }

  double getAllergiesFillPercentage() {
    if (_areAllergiesFilled()) {
      return 1;
    } else {
      return 0;
    }
  }

  double getIntolerancesFillPercentage() {
    if (_areIntolerancesFilled()) {
      return 1;
    } else {
      return 0.0;
    }
  }

  double getAversionsFillPercentage() {
    if (_isAversionsFilled()) {
      return 1.0;
    } else {
      return 0.0;
    }
  }

  int getNumberOfObjectives() => state.profile!.objectives!.length;

  double _calculatePercentage(int variablesNumber, int totalVariables) => (variablesNumber)/totalVariables;
  bool _isWaistMeasurementFilled() => state.profile!.physicalCharacteristics!.waistMeasurement != null || state.profile!.physicalCharacteristics!.waistMeasurement != 0;
  bool _isBodyFatFilled() => state.profile!.physicalCharacteristics!.bodyFat != null || state.profile!.physicalCharacteristics!.bodyFat != 0;
  bool _isMedicalSituationFilled() => state.profile!.medicalSituation != null && state.profile!.medicalSituation!.commonDiseases!.isNotEmpty;
  bool _isDietTypeFilled() => state.profile!.exclusions != null &&
      state.profile!.exclusions!.exclusions != null &&
      !state.profile!.exclusions!.exclusions!.contains(14) &&
      !state.profile!.exclusions!.exclusions!.contains(16) &&
      !state.profile!.exclusions!.exclusions!.contains(17);
  bool _isAversionsFilled() => state.profile!.foodAversions != null && state.profile!.foodAversions!.isNotEmpty;
  bool _isAnyAllergySelected() {
    final allergies = Allergens.listAllAllergens();
    bool isAnyAllergySelected = false;
    for (var allergen in allergies) {
      if (state.profile!.exclusions!.exclusions!.contains(allergen.id)) {
        isAnyAllergySelected = true;
      }
    }
    return isAnyAllergySelected;
  }
  bool _areAllergiesFilled() => state.profile!.exclusions != null && state.profile!.exclusions!.exclusions != null && _isAnyAllergySelected();
  bool _areIntolerancesFilled() => state.profile!.intolerances != null && state.profile!.intolerances!.isNotEmpty;

  bool areMandatoryFieldsComplete() {
    if (state.profile!.objectives!.isNotEmpty &&
        // !state.profile!.occupationActivityFactor.isNull() &&
        !state.profile!.physicalCharacteristics!.height.isNull() &&
        !state.profile!.physicalCharacteristics!.weight.isNull() &&
        !state.profile!.commonName.isNull() &&
        !state.profile!.sex.isNull() &&
        !state.profile!.birthDate.isNull()
    ) {
      return true;
    } else {
      return false;
    }
  }

  String buildMandatoryFieldsNotCompletedMessage(BuildContext context) {
    String error = AppLocalizations.of(context)!.mandatory_fields_not_filled_body;
    error = '''$error 
       
      ''';
    if (state.profile!.objectives!.isEmpty) {
      error = '''$error 
      ${AppLocalizations.of(context)!.objectives}
      ''';
    }
    // if (state.profile!.occupationActivityFactor.isNull()) {
    //   error = '''$error
    //   ${AppLocalizations.of(context)!.physical_activity}
    //   ''';
    // }
    if (state.profile!.physicalCharacteristics!.height.isNull()) {
      error = '''$error 
      ${AppLocalizations.of(context)!.height}
      ''';
    }
    if (state.profile!.physicalCharacteristics!.weight.isNull()) {
      error = '''$error 
      ${AppLocalizations.of(context)!.weight}
      ''';
    }
    if (state.profile!.commonName.isNull()) {
      error = '''$error 
      ${AppLocalizations.of(context)!.name}
      ''';
    }
    if (state.profile!.sex.isNull()) {
      error = '''$error
      ${AppLocalizations.of(context)!.sex}
      ''';
    }
    if (state.profile!.birthDate.isNull()) {
      error = '''$error 
      ${AppLocalizations.of(context)!.birthdate}
      ''';
    }

    return error;
  }

  bool? whichDietIsSelected(int? dietFromProfile, dynamic dietType) {
    if ((dietType.id == null && dietType.runtimeType == Vegetarian) && (dietFromProfile == OvoVegetarian().id || dietFromProfile == LactoOvoVegetarian().id || dietFromProfile == LactoVegetarian().id)) {
      return true;
    } else if (dietFromProfile == dietType.id) {
      return true;
    } else {
      false;
    }
    return null;
  }

  AversionsUIModel populateAversions(BuildContext context) {
    AversionsUIModel aversionsUIModel = AversionsUIModel(foodGroups: []);
    final foodsAndDrinksNames = state.foodsAndDrinksNamesMaster!.foodsAndDrinksNames!.getFoodsAndDrinkNamesOrEmpty();
    for (var recommendationGroup in state.recommendationGroupsMaster!.recommendationGroups) {
      List<SimpleItem> simpleItemsList = [];
      for (var food in foodsAndDrinksNames) {
        if (recommendationGroup.groups.contains(food.group)) {
          simpleItemsList.add(SimpleItem(name: food.translate(context), id: food.id!));
        }
      }
      simpleItemsList.sort((a,b) => a.name.compareTo(b.name));
      FoodGroup foodGroup = FoodGroup(
        id: recommendationGroup.id,
        name: recommendationGroup.translate(context),
        foodsList: simpleItemsList,
      );
      aversionsUIModel.foodGroups.add(foodGroup);
    }

    return aversionsUIModel;
  }

  FoodItemMaster findFoodNameFromFoodId(int foodId) {
    return state.foodsAndDrinksNamesMaster!.foodsAndDrinksNames!
        .getFoodsAndDrinkNamesOrEmpty()
        .firstWhere((foodItemMaster) => foodItemMaster.id == foodId, orElse: FoodItemMaster.empty);
  }

  List<ObjectiveInfoMaster> getObjectives(List<ObjectiveInfoMaster> combineList) {
    List<ObjectiveInfoMaster> a = [];
    for (int item in state.profile?.objectives?? []) {
      for (ObjectiveInfoMaster obj in combineList) {
        if (item == obj.id) {
          a.add(obj);
          // break;
        }
      }
    }
    return a;
  }

}