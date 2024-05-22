part of 'feces_urine_bloc.dart';

@immutable
abstract class FecesUrineEvent {}

class InitializationFecesEventAction extends FecesUrineEvent {
  final DateTime? dateTime;
  final Function? onFinish;

  InitializationFecesEventAction({this.dateTime, this.onFinish});
}

class InitializationUrineEventAction extends FecesUrineEvent {
  final DateTime? dateTime;
  final Function? onFinish;

  InitializationUrineEventAction({this.dateTime, this.onFinish});
}

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

class SelectedFacesDayEvents extends FecesUrineEvent {
  final DateTime dateTime;
  final Function onFinish;

  SelectedFacesDayEvents({required this.dateTime, required this.onFinish});
}

class SelectedUrineDayEvents extends FecesUrineEvent {
  final DateTime dateTime;
  final Function onFinish;

  SelectedUrineDayEvents({required this.dateTime, required this.onFinish});
}
