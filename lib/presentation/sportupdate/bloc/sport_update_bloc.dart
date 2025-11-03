import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/upload_sport_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

import '../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/masterfiles/sports_info_master.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'sport_update_event.dart';
part 'sport_update_state.dart';

class SportUpdateBloc extends Bloc<SportUpdateEvent, SportUpdateState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSportEventsInteractor uploadSportEventsInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;

  SportUpdateBloc({
    required this.getMasterFileInteractor,
    required this.uploadSportEventsInteractor,
    required this.saveSportEventInteractor,
  }) : super(SportUpdateState(isLoading: false)) {
    on<InitializeSportUpdateEvent>((event, emit) async {
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);

      emit(state.copyWith(isLoading: false));
    });

    on<AddSportFromNavSportUpdateEvent>((event, emit) {
      final sportEvent = mapToSportFavoriteFromEventComplete(event.sportEvent);
      state.sportSimpleEvent = sportEvent;

      emit(state.copyWith(isLoading: false));
    });

    on<AddSportSportUpdateEvent>((event, emit) {
      final listOfIds = state.sportSimpleEvent?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info!.indexOf(state.sportSimpleEvent!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info!.remove(state.sportSimpleEvent!.info![itemIndex]);
        state.sportSimpleEvent!.info!.add(event.sportInfo);
      } else {
        state.sportSimpleEvent?.info?.add(event.sportInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateEventDateSportUpdateEvent>((event, emit) {
      state.sportSimpleEvent?.eventDate = event.dateTime.millisecondsSinceEpoch;

      emit(state.copyWith(isLoading: false));
    });

    on<RemoveSportSportUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.sportSimpleEvent?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info!.indexOf(state.sportSimpleEvent!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info!.remove(state.sportSimpleEvent!.info![itemIndex]);
      }
      if (state.sportSimpleEvent?.info?.isEmpty == true) event.isGoBack.call();

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetMinutesSportUpdateEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.sportSimpleEvent!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info.orEmpty().indexOf(state.sportSimpleEvent!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info.orEmpty()[itemIndex].minutes = event.sportInfo.minutes;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetIntensitySportUpdateEvent>((event, emit) {
      if (state.sportSimpleEvent!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimpleEvent!.info.orEmpty().indexOf(state.sportSimpleEvent!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimpleEvent!.info.orEmpty()[itemIndex].intensity = event.sportInfo.intensity;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<FinishUpdateSportItemSportUpdateEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        final sportEventSimple = mapToSportEventSimpleFromAddFavoriteSport(state.sportSimpleEvent!);
        final sportEventComplete = await uploadSportEventsInteractor.execute(sportEventSimple);
        try {
          await saveSportEventInteractor.execute(sportEventComplete, true);

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
  }

  _clearFields() {

  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
  }

  bool? validateSportList() {
    return state.sportSimpleEvent?.info?.any((sport) {
      return sport.minutes.orZero() <= 0 || sport.intensity == null;
    },);
  }
}
