import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/liquidevents/liquid_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';

class CalendarRepositoryImpl extends CalendarRepository {
  final FoodEventsRepository foodEventsRepository;
  final SportEventsRepository sportEventsRepository;
  final LiquidEventsRepository liquidEventsRepository;
  final WaterEventsRepository waterEventsRepository;

  CalendarRepositoryImpl({
    required this.foodEventsRepository,
    required this.sportEventsRepository,
    required this.liquidEventsRepository,
    required this.waterEventsRepository,
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

}