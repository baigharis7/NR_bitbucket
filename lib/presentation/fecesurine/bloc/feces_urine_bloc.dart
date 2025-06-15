import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_faeces_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import '../../../domain/interactor/fecesurine/get_urine_by_date_interactor.dart';
import '../../../domain/models/profile/feces.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/events_helper.dart';

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
  final GetFaecesByDateInteractor getFaecesByDateInteractor;
  final GetUrineByDateInteractor getUrineByDateInteractor;

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
    required this.getFaecesByDateInteractor,
    required this.getUrineByDateInteractor,
  }) : super(FecesUrineState(isLoading: false)) {
    on<InitializationFecesEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      state.urinesList = Urines.listOfAllUrines();
      state.fecesEvents = await getFecesEventsInteractor.execute();
      state.facesDayEvents = await getFaecesByDateInteractor.execute(dateTime: event.dateTime);

      if (event.dateTime != null) state.fecesDate = event.dateTime;
      if (event.onFinish != null) event.onFinish?.call();
      emit(state.copyWith(isLoading: false));
    });

    on<InitializationUrineEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.urineEvents = await getUrineEventsInteractor.execute();
      state.urineDayEvents = await getUrineByDateInteractor.execute(dateTime: event.dateTime);

      if (event.dateTime != null) state.urineDate = event.dateTime;
      if (event.onFinish != null) event.onFinish?.call();
      emit(state.copyWith(isLoading: false));
    },);

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
      if (state.fecesId.isNull()) return;
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadFeces = UploadFeces(
          userId: getUserIdInteractor.execute(),
          eventId: state.fecesDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
          fecesId: state.fecesId ?? -1,
      );
      try {
        await uploadFecesInteractor.execute(uploadFeces);
        try {
          await saveFecesEventInteractor.execute(uploadFeces);
          add(InitializationFecesEventAction());
          _clearFields();
          // event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<UploadUrineEventAction>((event, emit) async {
      if (state.urineId.isNull()) return;
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadUrine = UploadFeces(
        userId: getUserIdInteractor.execute(),
        eventId: state.urineDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        fecesId: state.urineId ?? -1,
      );
      try {
        await uploadUrineInteractor.execute(uploadUrine);
        try {
          await saveUrineInteractor.execute(uploadUrine);
          add(InitializationUrineEventAction());
          _clearFields();
          // event.onFinish.call();
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
          add(InitializationFecesEventAction());
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
          add(InitializationUrineEventAction());
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    },);

    on<SelectedFacesDayEvents>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.facesDayEvents = [];
      for (UploadFeces item in state.fecesEvents.orEmpty()) {
        var dateTimeFromMilli = DateTimeHelper.dateTimeFromMilliseconds(item.eventId);
        if (dateTimeFromMilli?.year == event.dateTime.year && dateTimeFromMilli?.month == event.dateTime.month && dateTimeFromMilli?.day == event.dateTime.day) {
          state.facesDayEvents?.add(item);
        }
      }
      event.onFinish.call();
      emit(state.copyWith(isLoading: false));
    },);

    on<SelectedUrineDayEvents>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.urineDayEvents = [];
      for (UploadFeces item in state.urineEvents.orEmpty()) {
        var dateTimeFromMilli = DateTimeHelper.dateTimeFromMilliseconds(item.eventId);
        if (dateTimeFromMilli?.year == event.dateTime.year && dateTimeFromMilli?.month == event.dateTime.month && dateTimeFromMilli?.day == event.dateTime.day) {
          state.urineDayEvents?.add(item);
        }
      }
      event.onFinish.call();
      emit(state.copyWith(isLoading: false));
    },);
  }

  List<dynamic> getEventsForDay(List<dynamic> list, DateTime dateTime) {
    return EventsHelper.isEventFoundAgainstDate(list, dateTime);
  }



  void _clearFields() {
    state.fecesId = null;
    state.urineId = null;
  }
}
