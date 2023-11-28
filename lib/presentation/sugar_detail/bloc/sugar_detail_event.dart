part of 'sugar_detail_bloc.dart';

@immutable
abstract class SugarDetailEvent {}

class LoadSugarEventAction extends SugarDetailEvent {
  final SugarAndFiberModel sugarAndFiberModel;

  LoadSugarEventAction({required this.sugarAndFiberModel});
}
