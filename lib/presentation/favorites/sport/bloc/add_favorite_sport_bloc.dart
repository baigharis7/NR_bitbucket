import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/bloc/add_favorite_sport_state.dart';

import '../../../../domain/interactor/sportevents/upload_sport_events_interactor.dart';

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
      final eventDate = event.sportEventComplete.eventDate;
      state.sportsFavorite = event.sportEventComplete.info?.map((event) => SportFavorite(
        id: event.id,
        minutes: event.minutes,
        intensity: event.intensity,
        timeStart: event.timeStart.toString(),
        eventDate: eventDate,
        name_es: event.name_es,
        name_en: event.name_en,
      ),).toList();
      // state.isEdit = true;

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteCommentAction>((event, emit) {
      state.sportFavorite!.comment = event.comment;
      event.onFinish.call();

      emit(state.copyWith(isLoading: false));
    });

    on<SetSportFavoriteNameAction>((event, emit) {
      state.sportFavorite!.title = event.favoriteName;

      emit(state.copyWith(isLoading: false));
    });

    on<FinishAddingFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final userId = getUserIdInteractor.execute();
      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(state.sportFavorite!, userId);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(state.sportFavorite!, state.isEdit ?? false);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadingSportEventError));
      }
    });

    on<UpdateSportCommentAction>((event, emit) async {
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
      //   final sportEventSimple = SportEventSimple(
      //     userId: getUserIdInteractor.execute(),
      //     eventId: DateTime.now().millisecondsSinceEpoch,
      //     info: SportInfo(
      //       id: state.sportId,
      //       name_en: sportInfo.en,
      //       name_es: sportInfo.es,
      //       minutes: state.minutes,
      //       timeStart: calculateMillisecondsStart(state.timeStart!, state.dateStart!),
      //       intensity: state.intensity ?? 0,
      //     ),
      //     comment: state.comment,
      //   );

        try {
          // final sportEventComplete = await uploadSportsEventInteractor.execute(sportEventSimple);
          try {
            // await saveSportEventInteractor.execute(sportEventComplete, state.eventDate != null);

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
      // }
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

  bool isSportFavo(SportFavorite sportFavorite) {
    return state.sportsFavorite?.any((sportFav) => sportFav.name_es.toString() == sportFavorite.name_es.toString()) ?? false;
  }
}