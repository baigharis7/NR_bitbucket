part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? onError;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  List<UploadFeces>? fecesEvents;
  List<UploadFeces>? urineEvents;
  List<UploadFeces>? urineDayEvents;
  List<UploadFeces>? facesDayEvents;
  int? fecesId;
  int? urineId;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.fecesEvents,
    this.urineEvents,
    this.facesDayEvents,
    this.urineDayEvents,
    this.fecesId,
    this.urineId,
  });

  FecesUrineState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<Feces>? fecesList,
    List<Urines>? urinesList,
    List<UploadFeces>? fecesEvents,
    List<UploadFeces>? urineEvents,
    List<UploadFeces>? urineDayEvents,
    List<UploadFeces>? facesDayEvents,
    int? fecesId,
    int? urineId,
  }) {
    return FecesUrineState(
      isLoading: isLoading,
      onError: onError,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      fecesEvents: fecesEvents ?? this.fecesEvents,
      urineEvents: urineEvents ?? this.urineEvents,
      facesDayEvents: facesDayEvents ?? this.facesDayEvents,
      urineDayEvents: urineDayEvents ?? this.urineDayEvents,
      fecesId: fecesId ?? this.fecesId,
      urineId: urineId ?? this.urineId,
    );
  }
}
