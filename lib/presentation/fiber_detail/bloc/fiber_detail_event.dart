part of 'fiber_detail_bloc.dart';

@immutable
abstract class FiberDetailEvent {}

class LoadFiberEventAction extends FiberDetailEvent {
  final SugarAndFiberModel? sugarAndFiberModel;

  LoadFiberEventAction({required this.sugarAndFiberModel});
}
