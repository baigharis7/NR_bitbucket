part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? onError;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  int? fecesId;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.fecesId,
  });

  FecesUrineState copyWith(
      {required bool isLoading,
      ErrorTypes? onError,
      List<Feces>? fecesList,
      List<Urines>? urinesList,
      int? fecesId,
      UserProfileModel? profile,
      int? urinesSelected}) {
    return FecesUrineState(
      isLoading: isLoading,
      onError: onError,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      fecesId: fecesId ?? this.fecesId,
    );
  }
}
