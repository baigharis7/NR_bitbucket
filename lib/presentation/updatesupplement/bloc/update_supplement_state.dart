part of 'update_supplement_bloc.dart';

// @immutable
// abstract class UpdateSupplementState {}

class UpdateSupplementState {
  bool isLoading;
  ErrorTypes? onError;
  SupplementsInfoMaster? supplementsInfo;
  SupplementSimple? supplementObj;

  UpdateSupplementState({
    required this.isLoading,
    this.onError,
    this.supplementsInfo,
    this.supplementObj,
  });

  UpdateSupplementState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    SupplementsInfoMaster? supplementsInfo,
    SupplementSimple? supplementObj,
  }) {
    return UpdateSupplementState(
      isLoading: isLoading,
      onError: onError,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementObj: supplementObj ?? this.supplementObj,
    );
  }
}
