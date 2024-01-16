part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? error;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  int? fecesSelected;
  int? urinesSelected;

  FecesUrineState({required this.isLoading, this.error, this.fecesList, this.urinesList, this.fecesSelected, this.urinesSelected});

  FecesUrineState copyWith({required bool isLoading, ErrorTypes? error, List<Feces>? fecesList, List<Urines>? urinesList, int? fecesSelected, int? urinesSelected}) {
    return FecesUrineState(
      isLoading: isLoading,
      error: error,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      fecesSelected: fecesSelected ?? this.fecesSelected,
      urinesSelected: urinesSelected ?? this.urinesSelected,
    );
  }
}
