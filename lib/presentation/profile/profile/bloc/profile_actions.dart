import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

class ProfileActions {
  ProfileActions();
}

class InitializeStateFromRegistryAction extends ProfileActions {
  final BuildContext context;
  InitializeStateFromRegistryAction({required this.context});
}

class InitializeStateFromProfileAction extends ProfileActions {
  final BuildContext context;
  InitializeStateFromProfileAction({required this.context});
}

enum BodyParameters {
  height, weight, bodyFat, waist
}

class AddObjectiveToListAction extends ProfileActions {
  int id;
  AddObjectiveToListAction({required this.id});
}

class AddRadioObjectiveToListAction extends ProfileActions {
  int id;
  AddRadioObjectiveToListAction({required this.id});
}

class RefreshCommonNameAction extends ProfileActions {
  String commonName;
  RefreshCommonNameAction({required this.commonName});
}

class RefreshBirthdateAction extends ProfileActions {
  int birthdate;
  RefreshBirthdateAction({required this.birthdate});
}

class SetBodyParameterAction extends ProfileActions {
  int parameter;
  BodyParameters type;

  SetBodyParameterAction({required this.parameter, required this.type,});
}

class SetSexAction extends ProfileActions {
  SexType sex;

  SetSexAction({required this.sex});
}

class SetDietQuestionsCheckedAction extends ProfileActions {
  SetDietQuestionsCheckedAction();
}

class SetDietTypeAction extends ProfileActions {
  int? dietType;

  SetDietTypeAction({required this.dietType});
}

class AddAllergenAction extends ProfileActions {
  int allergenId;

  AddAllergenAction({required this.allergenId});
}

class AddIntolerancesAction extends ProfileActions {
  int intoleranceId;

  AddIntolerancesAction({required this.intoleranceId});
}

class ManageAversionsAction extends ProfileActions {
  int foodId;

  ManageAversionsAction({required this.foodId});
}

class RemoveAversionAction extends ProfileActions {
  int foodId;

  RemoveAversionAction({required this.foodId});
}

class ManageCommonDiseaseAction extends ProfileActions {
  int commonDiseaseId;

  ManageCommonDiseaseAction({required this.commonDiseaseId});
}

class AddOtherDiseaseAction extends ProfileActions {
  String otherDisease;

  AddOtherDiseaseAction({required this.otherDisease});
}

class SetPeriodRegularityAction extends ProfileActions {
  int periodRegularity;

  SetPeriodRegularityAction({required this.periodRegularity});
}

class SetPeriodDurationAction extends ProfileActions {
  int days;

  SetPeriodDurationAction({required this.days});
}

class SetLastPeriodDateAction extends ProfileActions {
  DateTime date;

  SetLastPeriodDateAction({required this.date});
}

class SetActivityTypeAction extends ProfileActions {
  double activityType;

  SetActivityTypeAction({required this.activityType});
}

class SaveChangesAction extends ProfileActions {

  SaveChangesAction();
}

class AddVegetarianDietsOptions extends ProfileActions {
  bool showVegetarianDiets;
  AddVegetarianDietsOptions({required this.showVegetarianDiets});
}

class StopShowingVegetarianDiets extends ProfileActions {
  StopShowingVegetarianDiets();
}

class FinishProfileAction extends ProfileActions {
  Function nextScreen;

  FinishProfileAction({required this.nextScreen});
}

class PerformLogOutAction extends ProfileActions {
  final Function goToLogin;

  PerformLogOutAction({required this.goToLogin});
}
