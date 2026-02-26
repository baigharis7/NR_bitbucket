part of 'supplements_bloc.dart';

// @immutable
abstract class SupplementsEvent {}

class InitializationSupplementsAction extends SupplementsEvent{}

class UpdateDateSupplementsAction extends SupplementsEvent {
  DateTime dateTime;

  UpdateDateSupplementsAction({required this.dateTime});
}

class UpdateScreenTitle extends SupplementsEvent {
  final String screenTitle;

  UpdateScreenTitle({required this.screenTitle});
}

class GetSupplementFromNavAction extends SupplementsEvent {
  final SupplementSimple supplementSimple;

  GetSupplementFromNavAction({required this.supplementSimple});
}

class AddSupplementInfoSupplementsAction extends SupplementsEvent{
  NutriInfo nutriInfo;

  AddSupplementInfoSupplementsAction({required this.nutriInfo});
}

class RemoveSupplementInfoSupplementsAction extends SupplementsEvent {
  NutriInfo nutriInfo;
  Function isGoBack;

  RemoveSupplementInfoSupplementsAction({required this.nutriInfo, required this.isGoBack});
}

class UpdateAmountSupplementsAction extends SupplementsEvent {
  NutriInfo nutriInfo;

  UpdateAmountSupplementsAction({required this.nutriInfo});
}

class UpdateNameSupplementsEvent extends SupplementsEvent {
  String name;

  UpdateNameSupplementsEvent({required this.name});
}

class UpdateFavoriteActionSupplementsEvent extends SupplementsEvent {
  bool isFavorite;

  UpdateFavoriteActionSupplementsEvent({required this.isFavorite});
}

class UpdateRoutineActionSupplementsEvent extends SupplementsEvent {
  bool isRoutine;

  UpdateRoutineActionSupplementsEvent({required this.isRoutine});
}

class UpdateTimeOfDaySupplementsEvent extends SupplementsEvent {
  String scheduleTime;

  UpdateTimeOfDaySupplementsEvent({required this.scheduleTime});
}

class UpdateDaysOfWeekSupplementsEvent extends SupplementsEvent {
  int weekDay;

  UpdateDaysOfWeekSupplementsEvent({required this.weekDay});
}

class SavingEventSupplementsAction extends SupplementsEvent {
  final Function onFinish;

  SavingEventSupplementsAction({required this.onFinish});
}

class FinishEventSupplementsAction extends SupplementsEvent{
  final Function onFinish;

  FinishEventSupplementsAction({required this.onFinish});
}

class FinishSupplementFavorite extends SupplementsEvent {
  final Function onFinish;

  FinishSupplementFavorite({required this.onFinish});
}

class FinishSupplementRoutineSupplementsEvent extends SupplementsEvent {
  final Function onFinish;

  FinishSupplementRoutineSupplementsEvent({required this.onFinish});
}

class FinishSupplementFavoriteSupplementsEvent extends SupplementsEvent {
  final SupplementSimple supplement;
  final Function onFinish;

  FinishSupplementFavoriteSupplementsEvent({required this.supplement, required this.onFinish});
}

class SwitchFavRecentTabSupplementsAction extends SupplementsEvent {
  final int tabIndex;

  SwitchFavRecentTabSupplementsAction({required this.tabIndex});
}