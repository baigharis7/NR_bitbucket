part of 'supplements_detail_bloc.dart';

// @immutable
// abstract class SupplementsDetailState {}

class SupplementsDetailState {
  bool isLoading;
  ErrorTypes? onError;
  DateTime? eventDate;

  SupplementsDetailState({
    required this.isLoading,
    this.onError,
    this.eventDate,
  });

  SupplementsDetailState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    DateTime? eventDate,
  }) {
    return SupplementsDetailState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}
