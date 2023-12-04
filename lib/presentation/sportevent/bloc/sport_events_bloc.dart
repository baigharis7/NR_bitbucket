import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_actions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/bloc/sport_events_state.dart';

class SportEventsBloc extends BaseBloc<SportEventsActions, SportEventsState> {
  final GetUserIdInteractor getUserIdInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;
  final UploadSportEventsInteractor uploadSportsEventInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;

  SportEventsBloc({
    required this.getUserIdInteractor,
    required this.saveSportEventInteractor,
    required this.uploadSportsEventInteractor,
    required this.getMasterFileInteractor,
    required this.getSportFavoritesInteractor,
  }) : super(SportEventsState(
    isLoading: false,
    dateStart: DateTimeHelper().provideCurrentDate(),
    sportEventSimple: SportEventSimple(),
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    isEdit: false,
    info: [],
    sportFromFavorite: [],
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      _clearFields();
      state.sportsFavorite = await getSportFavoritesInteractor.execute();
      state.sportEventSimple!.userId = getUserIdInteractor.execute();
      if (state.sportsInfo!.sportsInfoMaster.isEmpty) {
        state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetIntensityAction>((event, emit) {
      // int intensitiesNumber = findSportByName(state.sportName.orEmpty(), event.currentLanguage).mets;
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info![itemIndex].intensity = event.sportInfo.intensity;
        // state.info!.remove(state.info![itemIndex]);
        // state.info!.add(event.sportInfo);
      }
      // if (intensitiesNumber == 1) {
      //   state.intensity = 0;
      // } else if (intensitiesNumber > 1) {
      //   state.intensity = event.intensity;
      // }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetEventSportNameAction>((event, emit) {
      state.eventSportName = event.sportEventName;

      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<SetSportNameAction>((event, emit) {
      state.sportName = event.sportName;
      state.sportId = event.sportId;
      state.sportIntensities = EventsHelper().getChosenSportIntensities(state.sportName, state.sportsInfo!, event.currentLanguage);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetDateStartAction>((event, emit) {
      state.dateStart = DateTimeHelper().provideCurrentDate();

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetTimeStartAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info![itemIndex].timeStart = event.sportInfo.timeStart;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetMinutesAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info![itemIndex].minutes = event.sportInfo.minutes;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSportEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.info!.map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.info!.indexOf(state.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.info!.remove(state.info![itemIndex]);
        state.info!.add(event.sportInfo);
      } else {
        state.info!.add(event.sportInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<AddSportFromFavoriteAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      state.eventSportName = event.sportInfo.title;
      state.comment = event.sportInfo.comment;
      state.sportFromFavorite = event.sportInfo.info;
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<RemoveSportEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      state.info!.remove(event.sportInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishSportEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      // if (state.timeStart == null) {
      //   state.onError = ErrorTypes.sportEventTimeStartError;
      //   emit(state.copyWith(isLoading: false, onError: state.onError,));
      // } else if (state.dateStart == null) {
      //   state.onError = ErrorTypes.sportEventDateStartError;
      //   emit(state.copyWith(isLoading: false, onError: state.onError,));
      // } else if (state.sportId == null) {
      //   state.onError = ErrorTypes.sportEventSportIdError;
      //   emit(state.copyWith(isLoading: false, onError: state.onError,));
      // } else if (state.intensity == null && state.sportIntensities! > 1) {
      //   state.onError = ErrorTypes.sportEventIntensityStartError;
      //   emit(state.copyWith(isLoading: false, onError: state.onError,));
      // } else if (state.minutes == null) {
      //   state.onError = ErrorTypes.sportEventMinutesStartError;
      //   emit(state.copyWith(isLoading: false, onError: state.onError,));
      // } else {
      //   final sportInfo = findSportById(state.sportId!);
        final sportEventSimple = SportEventSimple(
          userId: getUserIdInteractor.execute(),
          eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
          info: state.info,
          comment: state.comment,
          sportName: state.eventSportName,
        );

        try {
          final sportEventComplete = await uploadSportsEventInteractor.execute(sportEventSimple);
          try {
            await saveSportEventInteractor.execute(sportEventComplete, state.isEdit ?? false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            state.onError = ErrorTypes.locallySavingSportEventError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
          }
        } catch (error) {
          state.onError = ErrorTypes.uploadingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      });

    on<FinishSportFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
        final sportEventSimple = SportEventSimple(
          userId: getUserIdInteractor.execute(),
          eventId: state.eventDate ?? DateTime.now().millisecondsSinceEpoch,
          info: state.sportFromFavorite?.map((favSport) => SportInfo(id: favSport.id, minutes: favSport.minutes, intensity: favSport.intensity, timeStart: favSport.timeStart, name_en: favSport.name_en, name_es: favSport.name_es)).toList(),
          comment: state.comment,
          sportName: state.eventSportName,
        );

        try {
          final sportEventComplete = await uploadSportsEventInteractor.execute(sportEventSimple);
          try {
            await saveSportEventInteractor.execute(sportEventComplete, false);

            _clearFields();
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            state.onError = ErrorTypes.locallySavingSportEventError;
            emit(state.copyWith(isLoading: false, onError: state.onError,));
          }
        } catch (error) {
          state.onError = ErrorTypes.uploadingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      });

    // on<ReceiveSportEventInfoAction>((event, emit) async {
    //   final dateTimeHelper = DateTimeHelper();
    //   state.sportEventSimple = event.sportEventSimple;
    //   state.minutes = event.sportEventSimple.info!.minutes;
    //   state.intensity = event.sportEventSimple.info!.intensity;
    //   state.timeStart = dateTimeHelper.setTimeOfDayFromMillis(event.sportEventSimple.info!.timeStart!);
    //   state.sportName = event.sportEventSimple.info!.translate(event.context);
    //   state.sportId = event.sportEventSimple.info!.id;
    //   state.dateStart = dateTimeHelper.setDateFromMilliseconds(event.sportEventSimple.info!.timeStart!);
    //   state.eventDate = event.sportEventSimple.info!.timeStart;
    //   state.isEdit = true;
    //   if (state.sportsInfo!.sportsInfoMaster.isEmpty) {
    //     state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
    //   }
    //
    //   emit(state.copyWith(isLoading: false, onError: null));
    // });

    on<ResetSportInfoAction>((event, emit) {
      _clearFields();
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<ReceiveEventDateAction>((event, emit) {
      state.eventDate = event.eventDate.millisecondsSinceEpoch;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<AddSportEventFromDetailNavigation>((event, emit) {
      state.eventDate = event.sportEventComplete.eventDate;
      state.eventSportName = event.sportEventComplete.sportName;
      state.comment = event.sportEventComplete.comment;
      state.isEdit = true;
      state.info = event.sportEventComplete.info?.map((sport) => SportInfo(id: sport.id, minutes: sport.minutes, intensity: sport.intensity, timeStart: sport.timeStart, name_en: sport.name_en, name_es: sport.name_es)).toList();
      // emit(state.copyWith(isLoading: false, onError: null));
    },);
  }


  SportInfoMaster findSportByName(String name, String currentLanguage) {
    final sport = state.sportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport;
  }

  int findSportIdByName(String name, String currentLanguage) {
    final sport = state.sportsInfo!.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == name;
      } else {
        return sport.en == name;
      }
    });
    return sport.id;
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
    }

  int calculateMillisecondsStart(TimeOfDay timeStart, DateTime dateStart) {
    DateTime dateTime = DateTime(dateStart.year, dateStart.month, dateStart.day, timeStart.hour, timeStart.minute);
    return dateTime.millisecondsSinceEpoch;
  }

  void _clearFields() {
    state.info = [];
    state.sportFromFavorite = [];
    state.eventSportName = null;
    state.comment = null;
    state.isEdit = false;
    state.eventDate = null;
  }

  bool validateSportList() {
    return state.info?.any((sport) {
      return sport.minutes == null || sport.intensity == null || sport.timeStart == null;
    },) ?? true;
  }
}