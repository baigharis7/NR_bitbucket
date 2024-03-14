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
  int? fecesId;
  int? urineId;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.fecesEvents,
    this.urineEvents,
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
      fecesId: fecesId ?? this.fecesId,
      urineId: urineId ?? this.urineId,
    );
  }
}
