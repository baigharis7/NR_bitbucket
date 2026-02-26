part of 'supplements_bloc.dart';

// @immutable
// abstract class SupplementsState {}

class SupplementsState {
  bool isLoading;
  ErrorTypes? onError;
  String? screenTitle;
  bool? isEdit;
  UserProfileModel? userProfile;
  SupplementsInfoMaster? supplementsInfo;
  List<SupplementSimple>? supplementFavorites;
  SupplementSimple? supplementObj;
  List<SupplementSimple>? recentSupplements;
  int favRecentTab;

  SupplementsState({
    required this.isLoading,
    this.onError,
    this.screenTitle,
    this.isEdit,
    this.userProfile,
    this.supplementsInfo,
    this.supplementFavorites,
    this.supplementObj,
    this.recentSupplements,
    this.favRecentTab = 0,
  });

  SupplementsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    String? screenTitle,
    bool? isEdit,
    UserProfileModel? userProfile,
    SupplementsInfoMaster? supplementsInfo,
    List<SupplementSimple>? supplementFavorites,
    SupplementSimple? supplementObj,
    List<SupplementSimple>? recentSupplements,
    int? favRecentTab,
  }) {
    return SupplementsState(
      isLoading: isLoading,
      onError: onError,
      isEdit: isEdit ?? this.isEdit,
      screenTitle: screenTitle ?? this.screenTitle,
      userProfile: userProfile ?? this.userProfile,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementFavorites: supplementFavorites ?? this.supplementFavorites,
      supplementObj: supplementObj ?? this.supplementObj,
      recentSupplements: recentSupplements ?? this.recentSupplements,
      favRecentTab: favRecentTab ?? this.favRecentTab,
    );
  }
}
