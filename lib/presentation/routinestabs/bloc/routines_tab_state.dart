part of 'routines_tab_bloc.dart';

// @immutable
// abstract class RoutinesTabState {}

class RoutinesTabState {
  bool isLoading;
  ErrorTypes? onError;

  RoutinesTabState({required this.isLoading, this.onError});

  RoutinesTabState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
  }) {
    return RoutinesTabState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
    );
  }
}
