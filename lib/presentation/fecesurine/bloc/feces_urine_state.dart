part of 'feces_urine_bloc.dart';

// @immutable
// abstract class FecesUrineState {}

class FecesUrineState {
  bool isLoading;
  ErrorTypes? onError;
  List<Feces>? fecesList;
  List<Urines>? urinesList;
  UserProfileModel? profile;

  FecesUrineState({
    required this.isLoading,
    this.onError,
    this.fecesList,
    this.urinesList,
    this.profile,
  });

  FecesUrineState copyWith(
      {required bool isLoading,
      ErrorTypes? onError,
      List<Feces>? fecesList,
      List<Urines>? urinesList,
      UserProfileModel? profile,
      int? fecesSelected,
      int? urinesSelected}) {
    return FecesUrineState(
      isLoading: isLoading,
      onError: onError,
      fecesList: fecesList ?? this.fecesList,
      urinesList: urinesList ?? this.urinesList,
      profile: profile ?? this.profile,
    );
  }
}
