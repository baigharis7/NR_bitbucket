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

  RemoveSupplementInfoSupplementsAction({required this.nutriInfo});
}

class UpdateAmountSupplementsAction extends SupplementsEvent{
  NutriInfo nutriInfo;

  UpdateAmountSupplementsAction({required this.nutriInfo});
}

class SavingEventSupplementsAction extends SupplementsEvent {}

class FinishEventSupplementsAction extends SupplementsEvent{}
