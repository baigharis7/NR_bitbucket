import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_state.dart';

class JournalSportBloc extends BaseBloc<JournalSportActions, JournalSportState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetUserKcalInteractor getUserKcalInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  JournalSportBloc({
    required this.getMasterFileInteractor,
    required this.getUserKcalInteractor,
    required this.getTodaySportsInteractor,
    required this.getWeekSportsInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(
    JournalSportState(
      isLoading: false,
      todaySportEvents: [],
      showCard: false,
    ),
  ) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.sportsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.userKcal = await getUserKcalInteractor.execute();
      state.todaySportEvents = await getTodaySportsInteractor.execute();
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
  }

  String getSportName(int sportId, BuildContext context) {
    return state.sportsInfoMaster!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId).translate(context);
  }

}