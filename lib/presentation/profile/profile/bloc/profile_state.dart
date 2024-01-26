import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/activity_by_occupation_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/allergens.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/common_diseases.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/diet_type.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/intolerances.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/profile/model/aversions_ui_model.dart';

import '../../../../domain/models/profile/height_weight_units.dart';

class ProfileState {
  bool isLoading;
  ErrorTypes? onError;
  UserProfileModel? profile;
  ObjectivesInfoMaster? objectivesInfoMaster;
  bool? areDietQuestionsChecked;
  List<DietType>? dietTypes;
  List<Allergens>? allergens;
  List<Intolerances>? intolerances;
  FoodsAndDrinksNamesMaster? foodsAndDrinksNamesMaster;
  List<CommonDiseases>? commonDiseases;
  bool? registryEnded;
  bool? isFemale;
  List<ActivityByOccupationType>? activityTypes;
  bool? showVegetarianDiets;
  RecommendationGroupsMaster? recommendationGroupsMaster;
  AversionsUIModel? aversionsUI;
  List<ObjectiveInfoMaster>? filteredObjectives;
  bool? isMenstruation;
  bool? isCold;
  HeightWeightUnits? unitWeightHeight;

  ProfileState({
    required this.isLoading,
    this.onError,
    this.profile,
    this.objectivesInfoMaster,
    this.areDietQuestionsChecked = false,
    this.dietTypes,
    this.allergens,
    this.intolerances,
    this.foodsAndDrinksNamesMaster,
    this.commonDiseases,
    this.registryEnded,
    this.isFemale = false,
    this.activityTypes,
    this.showVegetarianDiets,
    this.recommendationGroupsMaster,
    this.aversionsUI,
    this.filteredObjectives,
    this.isMenstruation,
    this.isCold,
    this.unitWeightHeight,
  });

  ProfileState copyWith({
    required bool isLoading,
    required ErrorTypes? onError,
    UserProfileModel? profileModel,
    ObjectivesInfoMaster? objectivesInfoMaster,
    bool? areDietQuestionsChecked,
    List<DietType>? dietTypes,
    List<Allergens>? allergens,
    List<Intolerances>? intolerances,
    FoodsAndDrinksNamesMaster? foodsAndDrinksNamesMaster,
    List<CommonDiseases>? commonDiseases,
    bool? registryEnded,
    bool? isFemale,
    List<ActivityByOccupationType>? activityTypes,
    bool? showVegetarianDiets,
    RecommendationGroupsMaster? recommendationGroupsMaster,
    AversionsUIModel? aversionsUI,
    List<ObjectiveInfoMaster>? filteredObjectives,
    bool? isMenstruation,
    bool? isCold,
    HeightWeightUnits? unitWeightHeight,
  }) {
    return ProfileState(
      isLoading: isLoading,
      onError: onError,
      profile: profile,
      objectivesInfoMaster: objectivesInfoMaster ?? this.objectivesInfoMaster,
      areDietQuestionsChecked: areDietQuestionsChecked ?? this.areDietQuestionsChecked,
      dietTypes: dietTypes ?? this.dietTypes,
      allergens: allergens ?? this.allergens,
      intolerances: intolerances ?? this.intolerances,
      foodsAndDrinksNamesMaster: foodsAndDrinksNamesMaster ?? this.foodsAndDrinksNamesMaster,
      commonDiseases: commonDiseases ?? this.commonDiseases,
      registryEnded: registryEnded ?? this.registryEnded,
      isFemale: isFemale ?? this.isFemale,
      activityTypes: activityTypes ?? this.activityTypes,
      showVegetarianDiets: showVegetarianDiets ?? this.showVegetarianDiets,
      recommendationGroupsMaster: recommendationGroupsMaster ?? this.recommendationGroupsMaster,
      aversionsUI: aversionsUI ?? this.aversionsUI,
      filteredObjectives: filteredObjectives ?? this.filteredObjectives,
      isMenstruation: isMenstruation ?? this.isMenstruation,
      isCold: isCold ?? this.isCold,
      unitWeightHeight: unitWeightHeight ?? this.unitWeightHeight,
    );
  }
}

