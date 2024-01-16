part of 'feces_urine_bloc.dart';

@immutable
abstract class FecesUrineEvent {}

class InitializationEventAction extends FecesUrineEvent {}

class UpdateUrineEventAction extends FecesUrineEvent {
  final int? urineId;

  UpdateUrineEventAction({required this.urineId});
}

class UpdateFecesEventAction extends FecesUrineEvent {
  final int? feceId;

  UpdateFecesEventAction({required this.feceId});
}
