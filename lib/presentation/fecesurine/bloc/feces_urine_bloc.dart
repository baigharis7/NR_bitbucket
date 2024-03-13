import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../data/api/profile/model/user_profile_response.dart';
import '../../../domain/interactor/profile/upload_profile_interactor.dart';
import '../../../domain/models/profile/feces.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'feces_urine_event.dart';

part 'feces_urine_state.dart';

class FecesUrineBloc extends Bloc<FecesUrineEvent, FecesUrineState> {
  final GetUserIdInteractor getUserIdInteractor;
  final UploadFecesInteractor uploadFecesInteractor;

  FecesUrineBloc({
    required this.getUserIdInteractor,
    required this.uploadFecesInteractor,
  }) : super(FecesUrineState(isLoading: false)) {
    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      state.urinesList = Urines.listOfAllUrines();

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFecesEventAction>(
      (event, emit) {
        emit(state.copyWith(isLoading: true));
        state.fecesId = event.feceId;

        emit(state.copyWith(isLoading: false));
      },
    );

    on<UpdateUrineEventAction>(
      (event, emit) {
        emit(state.copyWith(isLoading: true));
        // state.profile?.urine = event.urineId;

        emit(state.copyWith(isLoading: false));
      },
    );

    on<UploadFecesEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadFeces = UploadFeces(
          userId: getUserIdInteractor.execute(),
          eventId: DateTime.now().millisecondsSinceEpoch,
          fecesId: state.fecesId ?? -1,
      );
      try {
        await uploadFecesInteractor.execute(uploadFeces);
        event.onFinish.call();
        emit(state.copyWith(isLoading: false, onError: null));
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);
  }
}
