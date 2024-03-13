part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? onError;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  List<UploadFeces>? fecesEvents;
  int? fecesId;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.fecesEvents,
    this.fecesId,
  });

  FecesUrineState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<Feces>? fecesList,
    List<Urines>? urinesList,
    List<UploadFeces>? fecesEvents,
    int? fecesId,
    int? urinesSelected,
  }) {
    return FecesUrineState(
      isLoading: isLoading,
      onError: onError,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      fecesEvents: fecesEvents ?? this.fecesEvents,
      fecesId: fecesId ?? this.fecesId,
    );
  }
}
