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

    on<InitializeFecesUrineEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      add(InitializationFecesEventAction());

      add(InitializationUrineEventAction());
      emit(state.copyWith(isLoading: false));
    });

    on<InitializationFecesEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      // state.facesDayEvents = await getFaecesByDateInteractor.execute(dateTime: state.calendarDateTime);
      final prev14DaysEvents = await getFaecesByDateInteractor.execute(days: 14);
      state.chart14DaysData = getPrevDaysData(list: prev14DaysEvents);
      state.chart14DaysData.orEmpty().removeWhere((element) => element['fecesId'] == 0);

      emit(state.copyWith(isLoading: false));
    });

    on<InitializationUrineEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.urinesList = Urines.listOfAllUrines();
      // final urineEvents = await getUrineByDateInteractor.execute(dateTime: state.calendarDateTime);
      // state.urineDayEvents = urineEvents;
      final urineChart14DaysData = await getUrineByDateInteractor.execute(days: 14);
      state.urineChart14DaysData = getPrevDaysData(list: urineChart14DaysData);

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateFecesEventAction>((event, emit) {
        emit(state.copyWith(isLoading: true));
        state.fecesId = state.fecesId == event.feceId ? null : event.feceId;

        emit(state.copyWith(isLoading: false));
      },);

    on<UpdateUrineEventAction>((event, emit) {
        emit(state.copyWith(isLoading: true));
        state.urineId = state.urineId == event.urineId ? null : event.urineId;

        emit(state.copyWith(isLoading: false));
      },);

    on<UploadFecesEventAction>((event, emit) async {
      if (state.fecesId.isNull()) return;
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadFeces = UploadFeces(
          userId: getUserIdInteractor.execute(),
          eventId: state.calendarDateTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
          fecesId: state.fecesId ?? -1,
      );
      try {
        await uploadFecesInteractor.execute(uploadFeces);
        try {
          await saveFecesEventInteractor.execute(uploadFeces);
          state.facesDayEvents = await getFaecesByDateInteractor.execute(dateTime: state.calendarDateTime);
          _clearFields();
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
      if (state.urineId.isNull()) return;
      emit(state.copyWith(isLoading: true));
      UploadFeces uploadUrine = UploadFeces(
        userId: getUserIdInteractor.execute(),
        eventId: state.calendarDateTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        fecesId: state.urineId ?? -1,
      );
      try {
        await uploadUrineInteractor.execute(uploadUrine);
        try {
          await saveUrineInteractor.execute(uploadUrine);
          state.urineDayEvents = await getUrineByDateInteractor.execute(dateTime: state.calendarDateTime);
          _clearFields();
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
          state.facesDayEvents = await getFaecesByDateInteractor.execute(dateTime: state.calendarDateTime);
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
          state.urineDayEvents = await getUrineByDateInteractor.execute(dateTime: state.calendarDateTime);
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

    on<UpdateCalendarDateFecesUrineEventAction>((event, emit) async {
      state.calendarDateTime = event.dateTime;
      final fecesDayList = await getFaecesByDateInteractor.execute(dateTime: event.dateTime);
      state.facesDayEvents = fecesDayList;
      final urineDayList = await getUrineByDateInteractor.execute(dateTime: event.dateTime);
      state.urineDayEvents = urineDayList;

      final prev14DaysEvents = await getFaecesByDateInteractor.execute(dateTime: event.dateTime, days: 14);
      state.chart14DaysData = getPrevDaysData(list: prev14DaysEvents);
      state.chart14DaysData.orEmpty().removeWhere((element) => element['fecesId'] == 0);

      final urineChart14DaysData = await getUrineByDateInteractor.execute(dateTime: event.dateTime, days: 14);
      state.urineChart14DaysData = getPrevDaysData(list: urineChart14DaysData);

      emit(state.copyWith(isLoading: false));
    });

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

  List<Map<String, dynamic>> getPrevDaysData({required List<UploadFeces> list}) {
    // final Map<int, int> fecesCountMap = {};
    //
    // for (var item in list) {
    //   int fecesId = item.fecesId;
    //   fecesCountMap[fecesId] = (fecesCountMap[fecesId] ?? 0) + 1;
    // }
    //
    // // Convert to list of maps (optional if you want structured result)
    // return fecesCountMap.entries.map((e) => {
    //   'fecesId': e.key,
    //   'count': (e.value / 14) * 100,
    // },).toList();

    // Initialize map with all IDs from 0 to 7 and default count 0
    final Map<int, int> fecesCountMap = {
      for (int i = 0; i <= 7; i++) i: 0,
    };

    // Count actual occurrences
    for (var item in list) {
      int fecesId = item.fecesId;
      if (fecesCountMap.containsKey(fecesId)) {
        fecesCountMap[fecesId] = fecesCountMap[fecesId]! + 1;
      }
    }

    // Convert to list of maps for consistency
    return fecesCountMap.entries
        .map((entry) => {
      'fecesId': entry.key,
      'count': (entry.value / 14) * 100,
    }).toList();
  }
}
