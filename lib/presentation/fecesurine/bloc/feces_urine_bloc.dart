import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor.dart';
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
  final GetFecesEventsInteractor getFecesEventsInteractor;
  final SaveFecesEventInteractor saveFecesEventInteractor;
  final UploadUrineInteractor uploadUrineInteractor;
  final SaveUrineInteractor saveUrineInteractor;
  final GetUrineEventsInteractor getUrineEventsInteractor;
  final DeleteFecesEventInteractor deleteFecesEventInteractor;
  final RemoveFecesEventInteractor removeFecesEventInteractor;
  final DeleteUrineEventInteractor deleteUrineEventInteractor;
  final RemoveUrineEventInteractor removeUrineEventInteractor;

  FecesUrineBloc({
    required this.getUserIdInteractor,
    required this.uploadFecesInteractor,
    required this.getFecesEventsInteractor,
    required this.saveFecesEventInteractor,
    required this.getUrineEventsInteractor,
    required this.uploadUrineInteractor,
    required this.saveUrineInteractor,
    required this.deleteFecesEventInteractor,
    required this.removeFecesEventInteractor,
    required this.deleteUrineEventInteractor,
    required this.removeUrineEventInteractor,
  }) : super(FecesUrineState(isLoading: false)) {
    on<InitializationEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      state.urinesList = Urines.listOfAllUrines();
      state.fecesEvents = await getFecesEventsInteractor.execute();
      state.urineEvents = await getUrineEventsInteractor.execute();

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
        state.urineId = event.urineId;

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
        try {
          await saveFecesEventInteractor.execute(uploadFeces);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<UploadUrineEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadUrine = UploadFeces(
        userId: getUserIdInteractor.execute(),
        eventId: DateTime.now().millisecondsSinceEpoch,
        fecesId: state.urineId ?? -1,
      );
      try {
        await uploadUrineInteractor.execute(uploadUrine);
        try {
          await saveUrineInteractor.execute(uploadUrine);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<DeleteFecesEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteFecesEventInteractor.execute(event.uploadFeces.userId, event.uploadFeces.eventId);
        try {
          await removeFecesEventInteractor.execute(event.uploadFeces);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<DeleteUrineEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteUrineEventInteractor.execute(event.uploadFeces.userId, event.uploadFeces.eventId);
        try {
          await removeUrineEventInteractor.execute(event.uploadFeces);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);
  }
}
