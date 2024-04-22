import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../domain/repository/supplements/supplements_repository.dart';

class CalendarRepositoryImpl extends CalendarRepository {
  final FoodEventsRepository foodEventsRepository;
  final SportEventsRepository sportEventsRepository;
  final LiquidEventsRepository liquidEventsRepository;
  final WaterEventsRepository waterEventsRepository;
  final SupplementsRepository supplementsRepository;

  CalendarRepositoryImpl({
    required this.foodEventsRepository,
    required this.sportEventsRepository,
    required this.liquidEventsRepository,
    required this.waterEventsRepository,
    required this.supplementsRepository,
  });

  @override
  Future<CalendarEvents> getAllEvents() async {
    final foodEvents = await foodEventsRepository.getAllFoodEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));
    final sportEvents = await sportEventsRepository.getAllSportEvents()..sort((a, b) => (a.eventDate).compareTo(b.eventDate));
    final liquidEvents = await liquidEventsRepository.getAllLiquidEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));
    final waterEvents = await waterEventsRepository.getAllWaterEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));

    return CalendarEvents(
      foodEvents: foodEvents,
      sportEvents: sportEvents,
      liquidEvents: liquidEvents,
      waterEvents: waterEvents,
    );
  }

  @override
  Future<DashboardAllCalendarEvents> getAllDashEvents() async {
    final foodEvents = await foodEventsRepository.getAllFoodEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));
    final sportEvents = await sportEventsRepository.getAllSportEvents()..sort((a, b) => (a.eventDate).compareTo(b.eventDate));
    final liquidEvents = await liquidEventsRepository.getAllLiquidEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));
    final waterEvents = await waterEventsRepository.getAllWaterEvents()..sort((a, b) => (a.eventDate!).compareTo(b.eventDate!));
    final creatineEvents = await supplementsRepository.getAllCreatineEvents()..sort((a, b) => (a.eventId!).compareTo(b.eventId!),);
    final collagenEvents = await supplementsRepository.getAllCollagenEvents()..sort((a, b) => (a.eventId!).compareTo(b.eventId!),);

    return DashboardAllCalendarEvents(
      foodEvents: foodEvents,
      sportEvents: sportEvents,
      liquidEvents: liquidEvents,
      waterEvents: waterEvents,
      creatineEvent: creatineEvents,
      collagenEvent: collagenEvents,
    );
  }

}