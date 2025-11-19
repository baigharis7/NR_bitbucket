part of 'settings_bloc.dart';

// @immutable
// abstract class SettingsState {}

class SettingsState {
  bool isLoading;
  ErrorTypes? onError;

  SettingsState({required this.isLoading, this.onError});

  SettingsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
  }) {
    return SettingsState(
      isLoading: isLoading,
      onError: onError,
    );
  }
}
