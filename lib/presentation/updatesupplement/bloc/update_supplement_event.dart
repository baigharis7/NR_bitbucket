part of 'update_supplement_bloc.dart';

@immutable
abstract class UpdateSupplementEvent {}

class InitializationUpdateSupplementEvent extends UpdateSupplementEvent {}

class SupplementFromArguments extends UpdateSupplementEvent {
  final SupplementSimple supplementSimple;

  SupplementFromArguments({required this.supplementSimple});
}

class AddSupplementInfoUpdateSupplementEvent extends UpdateSupplementEvent {
  final NutriInfo nutriInfo;

  AddSupplementInfoUpdateSupplementEvent({required this.nutriInfo});
}

class RemoveSupplementInfoUpdateSupplementEvent extends UpdateSupplementEvent {
  final NutriInfo nutriInfo;

  RemoveSupplementInfoUpdateSupplementEvent({required this.nutriInfo});
}

class UpdateNameSupplementUpdateSupplementEvent extends UpdateSupplementEvent {
  final String name;

  UpdateNameSupplementUpdateSupplementEvent({required this.name});
}

class UpdateTimeOfDaySupplementUpdateSupplementEvent extends UpdateSupplementEvent {
  final String scheduleTime;

  UpdateTimeOfDaySupplementUpdateSupplementEvent({required this.scheduleTime});
}

class UpdateDaysOfWeekSupplementUpdateSupplementEvent extends UpdateSupplementEvent {
  final int weekDay;

  UpdateDaysOfWeekSupplementUpdateSupplementEvent({required this.weekDay});
}

class UpdateAmountSupplementInfoUpdateSupplementEvent extends UpdateSupplementEvent {
  final NutriInfo nutriInfo;

  UpdateAmountSupplementInfoUpdateSupplementEvent({required this.nutriInfo});
}

class SavingUpdateSupplement extends UpdateSupplementEvent {
  final Function onFinish;

  SavingUpdateSupplement({required this.onFinish});
}

class SavingUpdateSupplementFavorite extends UpdateSupplementEvent {
  final Function onFinish;

  SavingUpdateSupplementFavorite({required this.onFinish});
}

class SavingUpdateSupplementRoutine extends UpdateSupplementEvent {
  final Function onFinish;

  SavingUpdateSupplementRoutine({required this.onFinish});
}


