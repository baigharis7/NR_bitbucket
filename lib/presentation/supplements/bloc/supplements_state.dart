part of 'supplements_bloc.dart';

// @immutable
// abstract class SupplementsState {}

class SupplementsState {
  bool isLoading;
  ErrorTypes? onError;
  UserProfileModel? userProfile;
  SupplementSimple? supplementObj;

  SupplementsState({
    required this.isLoading,
    this.onError,
    this.userProfile,
    this.supplementObj,
  });

  SupplementsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    UserProfileModel? userProfile,
    SupplementSimple? supplementObj,
  }) {
    return SupplementsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      userProfile: userProfile ?? this.userProfile,
      supplementObj: supplementObj ?? this.supplementObj,
    );
  }
}
