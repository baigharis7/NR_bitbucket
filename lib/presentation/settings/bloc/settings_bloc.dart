import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/fcm/fcm_api.dart';
import '../../../domain/interactor/login/erase_database_interactor.dart';
import '../../../domain/interactor/profile/sign_out_interactor.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/services/fcm_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SignOutInteractor signOutInteractor;
  final EraseDatabaseInteractor eraseDatabaseInteractor;
  final SharedPreferences sharedPreferences;
  final FcmApi? fcmApi;

  SettingsBloc({
    required this.signOutInteractor,
    required this.eraseDatabaseInteractor,
    required this.sharedPreferences,
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
        final signOutResult = await signOutInteractor.execute();
        final clearProfileResult = await eraseDatabaseInteractor.execute();
        final clearShared = await sharedPreferences.clear();
        emit(state.copyWith(isLoading: false, onError: null, ));
        event.goToLogin.call();
      } catch (errorSignOut) {
        state.onError = ErrorTypes.signOutError;
        emit(state.copyWith(isLoading: false, onError: null, ));
      }
    });
  }
}
