part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsInitialization extends SettingsEvent {}

class SettingsLogOut extends SettingsEvent {
  final Function goToLogin;

  SettingsLogOut({required this.goToLogin});
}