import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_state.dart';

import '../../../domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../infrastructure/errors/error_types.dart';

class JournalSportBloc extends BaseBloc<JournalSportActions, JournalSportState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserKcalInteractor getUserKcalInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;
  final GetUserIdInteractor getUserIdInteractor;

  JournalSportBloc({
    required this.getMasterFileInteractor,
    required this.getUserKcalInteractor,
    required this.getTodaySportsInteractor,
    required this.getWeekSportsInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getSportFavoritesInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
    required this.getUserIdInteractor,
  }) : super(
    JournalSportState(
      isLoading: false,
      todaySportEvents: [],
      sportsFavorite: [],
      showCard: false,
    ),
  ) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.sportsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.userKcal = await getUserKcalInteractor.execute();
      state.todaySportEvents = await getTodaySportsInteractor.execute();
      state.sportsFavorite = await getSportFavoritesInteractor.execute();
      final completeWeekData = await getWeekSportsInteractor.execute();
      state.weeklyData = EventsHelper().getWeeklyDataFormatted(completeWeekData, state.userKcal!);
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.addNewSportEvent.index);

      emit(state.copyWith(isLoading: false));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.addNewSportEvent.index);

      emit(state.copyWith(isLoading: false));
    });

    on<AddSportFavNameAction>((event, emit) {
      state.sportFavName = event.sportFavName;

      emit(state.copyWith(isLoading: false));
    },);

    on<FinishAddSportToFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final sportFavorite = AddSportFavorite(
        userId: getUserIdInteractor.execute(),
        eventDate: event.sportEvent.eventDate,
        info: event.sportEvent.info?.map((sport) => AddSportFavInfo(id: sport.id, name_en: sport.name_en, name_es: sport.name_es, minutes: sport.minutes, intensity: sport.intensity, timeStart: sport.timeStart)).toList(),
        comment: event.sportEvent.comment,
        title: state.sportFavName,
      );

      try {
        final sportEventComplete = await uploadSportFavoriteInteractor.execute(sportFavorite);
        try {
          await saveSportFavoriteInteractor.execute(sportFavorite, false);

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

  }

  String getSportName(int sportId, BuildContext context) {
    return state.sportsInfoMaster!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId).translate(context);
  }

  bool isSportFavorite(SportEventComplete sportEvent) {
    return state.sportsFavorite?.any((sportFav) => sportFav.title.toString() == sportEvent.sportName.toString()) ?? false;
  }

}