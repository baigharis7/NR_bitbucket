part of 'supplements_bloc.dart';

// @immutable
// abstract class SupplementsState {}

class SupplementsState {
  bool isLoading;
  ErrorTypes? onError;
  SupplementsInfoMaster? supplementsInfo;
  SupplementSimple? supplementObj;

  SupplementsState({
    required this.isLoading,
    this.onError,
    this.supplementsInfo,
    this.supplementObj,
  });

  SupplementsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    UserProfileModel? userProfile,
    SupplementsInfoMaster? supplementsInfo,
    SupplementSimple? supplementObj,
  }) {
    return SupplementsState(
      isLoading: isLoading,
      onError: onError,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementObj: supplementObj ?? this.supplementObj,
    );
  }
}
