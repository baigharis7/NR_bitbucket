import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_state.dart';

import '../../../../domain/interactor/sportevents/upload_sport_events_interactor.dart';
import '../../../../domain/models/sportevents/sport_event_simple.dart';

class AddFavoriteSportBloc extends BaseBloc<AddFavoriteSportActions, AddFavoriteSportState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final UploadSportEventsInteractor uploadSportsEventInteractor;
  final SaveSportEventInteractor saveSportEventInteractor;

  AddFavoriteSportBloc({
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
    required this.getSportFavoritesInteractor,
    required this.uploadSportsEventInteractor,
    required this.saveSportEventInteractor,
  }) : super(AddFavoriteSportState(
    isLoading: false,
    sportsInfo: SportsInfoMaster(sportsInfoMaster: []),
    sportFavorite: SportFavorite.empty(),
    sportsFavorite: [],
    isEdit: false,
  ),) {

    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.sportsFavorite = await getSportFavoritesInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteAction>((event, emit) {
      state.sportFavorite = event.sportFavorite;
      state.isEdit = true;

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportEventAction>((event, emit) {
      state.eventId = event.sportEventComplete.eventDate;
      state.comment = event.sportEventComplete.comment;
      state.sportName = event.sportEventComplete.sportName;
      state.sportInfo = event.sportEventComplete.info;
      state.isEdit = true;

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFromFavoriteAction>((event, emit) {
      state.eventId = event.sportFavorite.eventDate;
      state.comment = event.sportFavorite.comment;
      state.sportName = event.sportFavorite.title;
      state.sportInfo = event.sportFavorite.info?.map((favSportItem) => SportEventInfo(id: favSportItem.id ?? -1, name_en: favSportItem.name_en ?? '', name_es: favSportItem.name_es ?? '', intensity: favSportItem.intensity ?? -1, minutes: favSportItem.minutes ?? 0, timeStart: favSportItem.timeStart ?? 0, kcal: -1)).toList();
      state.isEdit = true;

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteCommentAction>((event, emit) {
      state.sportFavorite!.comment = event.comment;
      event.onFinish.call();

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteNameAction>((event, emit) {
      state.sportName = event.favoriteName;

      emit(state.copyWith(isLoading: false));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final sportFavorite = AddSportFavorite(
        userId: getUserIdInteractor.execute(),
        eventDate: state.eventId,
        info: state.sportInfo?.map((sport) => AddSportFavInfo(id: sport.id, name_en: sport.name_en, name_es: sport.name_es, minutes: sport.minutes, intensity: sport.intensity, timeStart: sport.timeStart)).toList(),
        comment: state.comment,
        title: state.sportName,
      );

      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(sportFavorite);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(sportFavorite, false);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    });

    on<FinishSportCommentEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final sportEventSimple = SportEventSimple(
        userId: getUserIdInteractor.execute(),
        eventId: state.eventId,
        info: state.sportInfo?.map((sport) => SportInfo(id: sport.id, name_en: sport.name_en, name_es: sport.name_es, minutes: sport.minutes, intensity: sport.intensity, timeStart: sport.timeStart)).toList(),
        comment: state.comment,
        sportName: state.sportName,
      );

      try {
        final sportEventComplete = await uploadSportsEventInteractor.execute(sportEventSimple);
        try {
          await saveSportEventInteractor.execute(sportEventComplete, state.comment != null);

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
    },);

    on<FinishFavoriteSportCommentAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final sportFavorite = AddSportFavorite(
        userId: getUserIdInteractor.execute(),
        eventDate: state.eventId,
        info: state.sportInfo?.map((sport) => AddSportFavInfo(id: sport.id, name_en: sport.name_en, name_es: sport.name_es, minutes: sport.minutes, intensity: sport.intensity, timeStart: sport.timeStart)).toList(),
        comment: state.comment,
        title: state.sportName,
      );

      try {
        final sportEventComplete = await uploadSportFavoriteInteractor.execute(sportFavorite);
        try {
          await saveSportFavoriteInteractor.execute(sportFavorite, state.comment != null);

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
    },);

    on<UpdateSportCommentEventAction>((event, emit) async {
      state.comment = event.comment;

      emit(state.copyWith(isLoading: false));
  });

  }

  String getIntensityName(BuildContext context, int? intensity) {
    switch (intensity) {
      case 0: return AppLocalizations.of(context)!.low;
      case 1: return AppLocalizations.of(context)!.medium;
      case 2: return AppLocalizations.of(context)!.high;
      default: return '';
    }
  }

  bool isSportFavo(SportEventComplete sportFavorite) {
    return state.sportsFavorite?.any((sportFav) => sportFav.title.toString() == sportFavorite.sportName.toString()) ?? false;
  }

}