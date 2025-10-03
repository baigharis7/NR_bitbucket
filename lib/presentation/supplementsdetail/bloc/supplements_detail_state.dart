part of 'supplements_detail_bloc.dart';

// @immutable
// abstract class SupplementsDetailState {}

class SupplementsDetailState {
  bool isLoading;
  ErrorTypes? onError;
  DateTime? eventDate;
  SupplementsInfoMaster? supplementsInfo;
  List<SupplementSimple> supplementEvents;

  SupplementsDetailState({
    required this.isLoading,
    this.onError,
    this.eventDate,
    this.supplementsInfo,
    required this.supplementEvents,
  });

  SupplementsDetailState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    DateTime? eventDate,
    SupplementsInfoMaster? supplementsInfo,
    List<SupplementSimple>? supplementEvents,
  }) {
    return SupplementsDetailState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      eventDate: eventDate ?? this.eventDate,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      supplementEvents: supplementEvents ?? this.supplementEvents,
    );
  }
}
