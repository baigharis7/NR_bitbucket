part of 'supplements_detail_bloc.dart';

// @immutable
// abstract class SupplementsDetailState {}

class SupplementsDetailState {
  bool isLoading;
  ErrorTypes? onError;
  DateTime? eventDate;
  UserProfileModel? userProfile;
  SupplementsInfoMaster? supplementsInfo;
  List<SupplementSimple> supplementEvents;
  List<SupplementSimple>? supplemntCreatines;
  List<SupplementSimple>? supplemntCollagens;
  int? totalAmountCreatine;
  int? totalAmountCollagen;

  SupplementsDetailState({
    required this.isLoading,
    this.onError,
    this.eventDate,
    this.userProfile,
    this.supplementsInfo,
    required this.supplementEvents,
    this.supplemntCreatines,
    this.supplemntCollagens,
    this.totalAmountCreatine,
    this.totalAmountCollagen,
  });

  SupplementsDetailState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    DateTime? eventDate,
    UserProfileModel? userProfile,
    SupplementsInfoMaster? supplementsInfo,
    List<SupplementSimple>? supplementEvents,
    List<SupplementSimple>? supplemntCreatines,
    List<SupplementSimple>? supplemntCollagens,
    int? totalAmountCreatine,
    int? totalAmountCollagen,
  }) {
    return SupplementsDetailState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      eventDate: eventDate ?? this.eventDate,
      userProfile: userProfile ?? this.userProfile,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementEvents: supplementEvents ?? this.supplementEvents,
      supplemntCreatines: supplemntCreatines ?? this.supplemntCreatines,
      supplemntCollagens: supplemntCollagens ?? this.supplemntCollagens,
      totalAmountCreatine: totalAmountCreatine ?? this.totalAmountCreatine,
      totalAmountCollagen: totalAmountCollagen ?? this.totalAmountCollagen,
    );
  }
}
