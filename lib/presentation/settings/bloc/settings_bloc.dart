import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/api/fcm/fcm_api.dart';
import '../../../domain/interactor/login/erase_database_interactor.dart';
import '../../../domain/interactor/preferences/clear_auth_preferences_interactor.dart';
import '../../../domain/interactor/profile/sign_out_interactor.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/services/fcm_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SignOutInteractor signOutInteractor;
  final EraseDatabaseInteractor eraseDatabaseInteractor;
  final ClearAuthPreferencesInteractor clearAuthPreferencesInteractor;
  final FcmApi? fcmApi;

  SettingsBloc({
    required this.signOutInteractor,
    required this.eraseDatabaseInteractor,
    required this.clearAuthPreferencesInteractor,
    this.fcmApi,
}) : super(SettingsState(isLoading: false)) {
    on<SettingsInitialization>((event, emit) {});

    on<SettingsLogOut>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, ));
      try {
        final token = FcmService.instance.token;
        if (token != null && fcmApi != null) {
          try { await fcmApi!.unregisterToken(token); } catch (_) {}
        }
        // Fire-and-forget Amplify sign-out (slow network call) so the user
        // doesn't stare at a spinner. Local clears MUST complete first so
        // the next account starts clean. Master files + their version prefs
        // are intentionally preserved — they're global app data and
        // re-downloading them is the main cost of a fresh login.
        signOutInteractor.execute();
        await eraseDatabaseInteractor.execute();
        await clearAuthPreferencesInteractor.execute();
        emit(state.copyWith(isLoading: false, onError: null, ));
        event.goToLogin.call();
      } catch (errorSignOut) {
        state.onError = ErrorTypes.signOutError;
        emit(state.copyWith(isLoading: false, onError: null, ));
      }
    });
  }
}
