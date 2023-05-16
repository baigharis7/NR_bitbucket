import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_kcal_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_state.dart';

class JournalLiquidBloc extends BaseBloc<JournalLiquidActions, JournalLiquidState> {
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;
  final GetUserKcalInteractor getUserKcalInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetWaterEventsTodayInteractor getWaterEventsTodayInteractor;

  JournalLiquidBloc({
    required this.getLiquidEventsOfTodayInteractor,
    required this.getWeekLiquidEventsInteractor,
    required this.getUserKcalInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getWaterEventsTodayInteractor,
  }) : super(JournalLiquidState(
    isLoading: false,
    todayLiquidEvents: [],
    weeklyData: [],
    userKcal: 0,
    kcalConsumed: 0,
    waterEvents: [],
    showCard: false,
  ),){
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.userKcal = await getUserKcalInteractor.execute();
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute();
      final completeWeekData = await getWeekLiquidEventsInteractor.execute();
      state.weeklyData = getWeeklyDataFormatted(completeWeekData);
      state.kcalConsumed = getTodayKcalFromLiquids(state.todayLiquidEvents!);
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.addNewLiquidEvent.index);
      state.waterEvents = await getWaterEventsTodayInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.addNewLiquidEvent.index);

      emit(state.copyWith(isLoading: false));
    });
  }

  List<Map<String, dynamic>> getWeeklyDataFormatted(List<FoodEventComplete> completeWeekData) {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in completeWeekData) {
      int weekDay = DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <FoodEventComplete>[];
      for (var event in completeWeekData) {
        final eventDate = DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfWeekDay.add(event);
        }
      }
      int kcalConsumed = 0;
      for (var event in eventsOfWeekDay) {
        kcalConsumed = kcalConsumed + event.eventKcals!;
      }

      weeklyData.add({'day': eventWeekDay, 'kcal': EventsHelper().getFractionToFillKcal(kcalConsumed, state.userKcal!)});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  int getTodayKcalFromLiquids(List<FoodEventComplete> events) {
    int kcals = 0;
    for (var event in events) {
      kcals = kcals + event.eventKcals!;
    }

    return kcals;
  }

}