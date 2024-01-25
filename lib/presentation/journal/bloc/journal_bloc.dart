import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_today_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/explaining_card_ui_model.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_state.dart';

import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';

class JournalBloc extends BaseBloc<JournalActions, JournalState> {
  final GetUserKcalInteractor getUserKcalInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final GetTodaySportsInteractor getTodaySportsInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetProfileInteractor getProfileInteractor;

  JournalBloc({
    required this.getUserKcalInteractor,
    required this.getWeekSportsInteractor,
    required this.getTodaySportsInteractor,
    required this.getWaterEventsTodayInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getLiquidEventsOfTodayInteractor,
    required this.getProfileInteractor,
  }) : super(JournalState(
    isLoading: false,
    onError: null,
    weeklyData: [],
    todaySportEvents: [],
    waterEvents: [],
    showGeneralCard: false,
    calendarCard: ExplainingCardUIModel(showCard: false, cardHasBeenShown: false),
    foodsCard: ExplainingCardUIModel(showCard: false, cardHasBeenShown: false),
    sportsCard: ExplainingCardUIModel(showCard: false, cardHasBeenShown: false),
    liquidsCard: ExplainingCardUIModel(showCard: false, cardHasBeenShown: false),
    userKcals: 0,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null, ),);
      state.userKcals = await getUserKcalInteractor.execute();
      state.userProfile = await getProfileInteractor.execute();
      final completeWeekData = await getWeekSportsInteractor.execute();
      state.weeklyData = EventsHelper().getWeeklyDataFormatted(completeWeekData, state.userKcals!);
      state.todaySportEvents = await getTodaySportsInteractor.execute();
      state.waterEvents = await getWaterEventsTodayInteractor.execute();
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute();
      state.showGeneralCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.journalGeneral.index);

      emit(state.copyWith(isLoading: false, onError: null),);
    });

    on<HideGeneralCardAction>((event, emit) {
      state.showGeneralCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.journalGeneral.index);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<CalendarClickAction>((event, emit) async {
      manageClickedCard(state.calendarCard!, ExplainingCardRefs.journalCalendar.index, event.action);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<HideCalendarCardAction>((event, emit) async {
      state.calendarCard!.showCard = false;
      state.calendarCard!.cardHasBeenShown = true;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.journalCalendar.index);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<FoodsClickAction>((event, emit) async {
      manageClickedCard(state.foodsCard!, ExplainingCardRefs.journalFoods.index, event.action);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<HideFoodsCardAction>((event, emit) async {
      state.foodsCard!.showCard = false;
      state.foodsCard!.cardHasBeenShown = true;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.journalFoods.index);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<SportsClickAction>((event, emit) async {
      manageClickedCard(state.sportsCard!, ExplainingCardRefs.journalSports.index, event.action);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<HideSportsCardAction>((event, emit) async {
      state.sportsCard!.showCard = false;
      state.sportsCard!.cardHasBeenShown = true;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.journalSports.index);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<LiquidsClickAction>((event, emit) async {
      manageClickedCard(state.liquidsCard!, ExplainingCardRefs.journalLiquids.index, event.action);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });

    on<HideLiquidsCardAction>((event, emit) async {
      state.liquidsCard!.showCard = false;
      state.liquidsCard!.cardHasBeenShown = true;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.journalLiquids.index);
      emit(state.copyWith(isLoading: false, onError: null, ));
    });


  }

  int getTodaysKcal(List<SportEventComplete> sportEvents) {
    int kcal = 0;
    for (var sportEvent in sportEvents) {
      kcal = kcal + (sportEvent.eventKcals ?? 0);
    }
    return kcal;
  }

  void manageClickedCard(ExplainingCardUIModel explainingCardUIModel, int explainingCardId, Function? action) async {
    if (!explainingCardUIModel.showCard!) {
      if (explainingCardUIModel.cardHasBeenShown!) {
        action?.call();
      } else {
        explainingCardUIModel.showCard = await isNecessaryToShowExplainingCardInteractor.execute(explainingCardId);
        if (!explainingCardUIModel.showCard!) {
          action?.call();
        }
      }
    } else {
      action?.call();
    }
  }

}