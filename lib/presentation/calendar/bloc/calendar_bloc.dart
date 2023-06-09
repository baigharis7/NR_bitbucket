import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/liquid_event_mappers.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_actions.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_state.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/sport/view/add_sport_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/liquidevent/view/add_liquid_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';

class CalendarBloc extends BaseBloc<CalendarActions, CalendarState> {
  final EventsHelper _eventsHelper = EventsHelper();
  final dateTimeHelper = DateTimeHelper();
  final GetAllEventsSortedByDateInteractor getAllEventsSortedByDateInteractor;
  
  CalendarBloc({
    required this.getAllEventsSortedByDateInteractor,
  }) : super(CalendarState(
    isLoading: false,
    allCalendarEvents: CalendarEvents.empty(),
    eventsOfDate: CalendarEvents.empty(),
    dayEvents: [],
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.allCalendarEvents = await getAllEventsSortedByDateInteractor.execute();
      emit(state.copyWith(isLoading: false));
    });

    on<SelectDayEventsActions>((event, emit) {
      state.dayEvents = getEventsForDay(event.selectedDay);
      emit(state.copyWith(isLoading: false));
    });

    on<RefreshEventsAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.allCalendarEvents = await getAllEventsSortedByDateInteractor.execute();
      state.dayEvents = getEventsForDay(event.selectedDay);
      emit(state.copyWith(isLoading: false));
    });
  }

  DateTime provideFirstDay() => dateTimeHelper.provideFirstDayForCalendar();
  DateTime provideFocusedDay() => dateTimeHelper.provideFocusedDayForCalendar();
  DateTime provideLastDay() => dateTimeHelper.provideLastDayForCalendar();

  List<dynamic> getEventsForDay(DateTime dateTime) {
    return _eventsHelper.getEventsFromGivenDate(state.allCalendarEvents!, dateTime);
  }

  String getEventTitle(BuildContext context, dynamic event) {
    if (event is FoodEventComplete) {
      return event.foodInfo!.map((e) => e.translate(context)).join(',');
    } else if (event is SportEventComplete) {
      return event.info.translate(context);
    } else if (event is WaterEventMaster) {
      return AppLocalizationsHelper.instance.translate('water');
    } else {
      return '';
    }
  }

  String? getRouteNameByEventTypeForFavorites(Type eventType) {
    switch (eventType) {
      case FoodEventComplete: return AddFoodFavoriteScreen.routeName;
      case SportEventComplete: return AddSportFavoriteScreen.routeName;
      case LiquidEventComplete: return AddLiquidEventScreen.routeName;
      case WaterEventMaster: return null;
    }
    return null;
  }

  String? getRouteNameByEventTypeForEditing(dynamic event) {
    switch (event.runtimeType) {
      case FoodEventComplete: return AddFoodEventScreen.routeName;
      case SportEventComplete: return AddSportEventScreen.routeName;
      case LiquidEventComplete: return AddLiquidEventScreen.routeName;
      case WaterEventMaster: return null;
    }
    return null;
  }

  dynamic getArgumentsAndTransformIntoFavorites(dynamic event) {
    switch (event.runtimeType) {
      case FoodEventComplete: return mapToFoodFavoriteList((event as FoodEventComplete).foodInfo!);
      case SportEventComplete: return mapToSportFavorite((event as SportEventComplete));
      case LiquidEventComplete: return mapToFoodFavoriteList((event as LiquidEventComplete).foodInfo!);
      case WaterEventMaster: return null;
    }
    return null;
  }

  dynamic getArgumentsToEditEvent(dynamic event) {
    switch (event.runtimeType) {
      case FoodEventComplete: return mapToFoodEventSimple((event as FoodEventComplete));
      case SportEventComplete: return mapToSportEventSimple((event as SportEventComplete));
      case LiquidEventComplete: return mapToLiquidEventSimple((event as LiquidEventComplete));
      case WaterEventMaster: return null;
    }
    return null;
  }
}