part of 'supplements_bloc.dart';

// @immutable
// abstract class SupplementsState {}

class SupplementsState {
  bool isLoading;
  ErrorTypes? onError;
  String? screenTitle;
  bool? isEdit;
  SupplementsInfoMaster? supplementsInfo;
  SupplementSimple? supplementObj;

  SupplementsState({
    required this.isLoading,
    this.onError,
    this.screenTitle,
    this.isEdit,
    this.supplementsInfo,
    this.supplementObj,
  });

  SupplementsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    String? screenTitle,
    bool? isEdit,
    UserProfileModel? userProfile,
    SupplementsInfoMaster? supplementsInfo,
    SupplementSimple? supplementObj,
  }) {
    return SupplementsState(
      isLoading: isLoading,
      onError: onError,
      isEdit: isEdit ?? this.isEdit,
      screenTitle: screenTitle ?? this.screenTitle,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementObj: supplementObj ?? this.supplementObj,
    );
  }
}
