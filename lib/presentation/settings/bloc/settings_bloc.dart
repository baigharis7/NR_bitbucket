import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/interactor/login/erase_database_interactor.dart';
import '../../../domain/interactor/profile/sign_out_interactor.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SignOutInteractor signOutInteractor;
  final EraseDatabaseInteractor eraseDatabaseInteractor;
  final SharedPreferences sharedPreferences;

  SettingsBloc({
    required this.signOutInteractor,
    required this.eraseDatabaseInteractor,
    required this.sharedPreferences,
}) : super(SettingsState(isLoading: false)) {
    on<SettingsInitialization>((event, emit) {});

    on<SettingsLogOut>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null, ));
      try {
        signOutInteractor.execute();
        event.goToLogin.call();
        eraseDatabaseInteractor.execute();
        sharedPreferences.clear();
        emit(state.copyWith(isLoading: false, onError: null, ));
      } catch (errorSignOut) {
        state.onError = ErrorTypes.signOutError;
        emit(state.copyWith(isLoading: false, onError: null, ));
      }
    });
  }
}
