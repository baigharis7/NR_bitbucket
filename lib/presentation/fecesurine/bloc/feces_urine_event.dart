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

class UploadFecesEventAction extends FecesUrineEvent {
  final Function onFinish;

  UploadFecesEventAction({required this.onFinish});
}

class UploadUrineEventAction extends FecesUrineEvent {
  final Function onFinish;

  UploadUrineEventAction({required this.onFinish});
}

class DeleteFecesEventAction extends FecesUrineEvent {
  final UploadFeces uploadFeces;
  final Function onFinish;

  DeleteFecesEventAction({required this.uploadFeces, required this.onFinish});
}

class DeleteUrineEventAction extends FecesUrineEvent {
  final UploadFeces uploadFeces;
  final Function onFinish;

  DeleteUrineEventAction({required this.uploadFeces, required this.onFinish});
}
