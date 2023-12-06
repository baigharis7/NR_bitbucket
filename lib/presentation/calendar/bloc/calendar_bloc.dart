import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/delete_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/remove_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/delete_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/remove_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
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
  final GetUserIdInteractor getUserIdInteractor;
  final RemoveFoodEventInteractor removeFoodEventInteractor;
  final DeleteFoodEventInteractor deleteFoodEventInteractor;
  final RemoveSportEventInteractor removeSportEventInteractor;
  final DeleteSportEventInteractor deleteSportEventInteractor;

  CalendarBloc({
    required this.getAllEventsSortedByDateInteractor,
    required this.getUserIdInteractor,
    required this.removeFoodEventInteractor,
    required this.deleteFoodEventInteractor,
    required this.removeSportEventInteractor,
    required this.deleteSportEventInteractor,
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

    on<RemoveFoodEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
          await deleteFoodEventInteractor.execute(getUserIdInteractor.execute(), event.foodEventComplete.eventDate ?? -1);
        try {
          final a = await removeFoodEventInteractor.execute(event.foodEventComplete);
          add(RefreshEventsAction(selectedDay: DateTime.fromMillisecondsSinceEpoch(event.foodEventComplete.eventDate ?? -1)));
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    },);

    on<RemoveSportEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteSportEventInteractor.execute(getUserIdInteractor.execute(), event.sportEventComplete.eventDate);

        try {
          await removeSportEventInteractor.execute(event.sportEventComplete);

          add(RefreshEventsAction(selectedDay: DateTime.fromMillisecondsSinceEpoch(event.sportEventComplete.eventDate)));
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
      }
    },);
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
      return event.info!.map((e) => e.translate(context)).join(',');
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
      // case FoodEventComplete: return AddFoodEventScreen.routeName;
      case FoodEventComplete: return AddFoodFavoriteScreen.routeName;
      // case SportEventComplete: return AddSportEventScreen.routeName;
      case SportEventComplete: return AddSportFavoriteScreen.routeName;
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
      // case FoodEventComplete: return mapToFoodEventSimple((event as FoodEventComplete));
      case FoodEventComplete: return event as FoodEventComplete;
      // case SportEventComplete: return mapToSportEventSimple((event as SportEventComplete));
      case SportEventComplete: return event as SportEventComplete;
      case LiquidEventComplete: return mapToLiquidEventSimple((event as LiquidEventComplete));
      case WaterEventMaster: return null;
    }
    return null;
  }

  dynamic getEventActionToDeleteEvent(dynamic event, Function onFinish) {
    switch (event.runtimeType) {
      case FoodEventComplete: return RemoveFoodEventAction(foodEventComplete: event as FoodEventComplete, onFinish: () => onFinish.call());
      case SportEventComplete: return RemoveSportEventAction(sportEventComplete: event as SportEventComplete, onFinish: () => onFinish.call());
    }
  }
}