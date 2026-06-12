import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

import '../../domain/models/foodevents/food_event_complete.dart';

class EventsHelper {
  final DateTimeHelper _dateTimeHelper = DateTimeHelper();

  EventsHelper();

  double getFractionToFillKcal(int kcal, int userKcal) {
    if (kcal != 0) {
      double returnQuantity = kcal / userKcal;
      if (returnQuantity > 1) returnQuantity = 1;
      return returnQuantity;
    } else {
      return kcal.toDouble();
    }
  }

  List<Map<String, dynamic>> getWeeklyDataFormatted(
      List<SportEventComplete> completeWeekData, int userKcal,) {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in completeWeekData) {
      int weekDay = _dateTimeHelper
          .setDateFromMilliseconds(event.eventDate)
          .weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      final eventsOfWeekDay = <SportEventComplete>[];
      for (var event in completeWeekData) {
        final eventDate = _dateTimeHelper
            .setDateFromMilliseconds(event.eventDate)
            .weekday;
        if (eventDate == eventWeekDay) {
          eventsOfWeekDay.add(event);
        }
      }
      int kcalConsumed = 0;
      for (var event in eventsOfWeekDay) {
        kcalConsumed = kcalConsumed + (event.eventKcals ?? 0);
      }

      weeklyData.add({
        'day': eventWeekDay,
        'kcal': getFractionToFillKcal(kcalConsumed, userKcal)
      });
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }

  List<double> generateWaterQuantities() => [0.2, 0.5, 0.75, 1, 1.5, 2];

  double getWaterIntakeAddition(List<WaterEventMaster>? waterEvents, List<LiquidEventComplete> liquidTodayEvents, List<FoodEventComplete> foodEvents) {
    double amount = 0.0;
    if (waterEvents != null && waterEvents.isNotEmpty) {
      for (var event in waterEvents) {
        amount = amount + event.qty!;
      }
    }

      if (liquidTodayEvents.isNotEmpty) {
        for (var liquidEvent in liquidTodayEvents) {
          for (var eventInfo in liquidEvent.foodInfo.orEmpty()) {
            // if (eventInfo.id == Constants.TAP_WATER_ID) {
              amount = amount + ((eventInfo.eventInfo?.qty ?? 0)/1000);
            // }
          }
        }
      }

      if (foodEvents.isNotEmpty) {
        for (var foodEvent in foodEvents) {
          for (var eventInfo in foodEvent.foodInfo.orEmpty()) {
            if (eventInfo.id == Constants.TAP_WATER_ID) {
              amount = amount + (((eventInfo.eventInfo?.qty ?? 0)/1000));
            }
          }
        }
      }
    if (amount < 0) amount = 0;
    return double.parse(amount.toStringAsFixed(2));
    }

  /// Consumed kcal for a given day from calendar events (food energyKcal + liquid eventKcals).
  int getConsumedKcalForDay(DashboardAllCalendarEvents? events, DateTime date) {
    if (events == null) return 0;
    double kcal = 0;
    for (final food in events.foodEvents ?? <FoodEventComplete>[]) {
      if (food.eventDate != null &&
          _dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, food.eventDate!)) {
        for (final info in food.foodInfo ?? <FoodInfo>[]) {
          kcal += info.params?.energyKcal ?? 0;
        }
      }
    }
    for (final liq in events.liquidEvents ?? <LiquidEventComplete>[]) {
      if (liq.eventDate != null &&
          _dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, liq.eventDate!)) {
        kcal += liq.eventKcals ?? 0;
      }
    }
    return kcal.toInt();
  }

  /// Burned kcal for a given day from sport events.
  int getBurnedKcalForDay(DashboardAllCalendarEvents? events, DateTime date) {
    if (events == null) return 0;
    int burned = 0;
    for (final sport in events.sportEvents ?? <SportEventComplete>[]) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, sport.eventDate)) {
        burned += sport.eventKcals ?? 0;
      }
    }
    return burned;
  }

  /// Water intake fraction for a given day from calendar events.
  double getWaterFractionForDay(DashboardAllCalendarEvents? events, DateTime date, double? totalWater) {
    if (events == null || (totalWater ?? 0) <= 0) return 0;
    final dayWater = (events.waterEvents ?? [])
        .where((w) => w.eventDate != null &&
            _dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, w.eventDate!))
        .toList();
    final dayLiquids = (events.liquidEvents ?? <LiquidEventComplete>[])
        .where((l) => l.eventDate != null &&
            _dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, l.eventDate!))
        .toList();
    final dayFoods = (events.foodEvents ?? <FoodEventComplete>[])
        .where((f) => f.eventDate != null &&
            _dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, f.eventDate!))
        .toList();
    return getWaterFractionToFillFromEvents(dayWater, dayLiquids, dayFoods, totalWater);
  }

  double getWaterFractionToFillFromEvents(List<WaterEventMaster>? waterEvents, List<LiquidEventComplete> liquidTodayEvents, List<FoodEventComplete> foodEvents, double? totalRequired) {
    // if (waterEvents != null && waterEvents.isNotEmpty) {
      return _getFractionToFillWater(getWaterIntakeAddition(waterEvents, liquidTodayEvents, foodEvents), totalRequired.orZero());
    // } else {
    //   return 0.0;
    // }
  }

  List getEventsFromGivenDate(CalendarEvents calendarEvents, DateTime date) {
    final calendarEvent = CalendarEvents(
      foodEvents: [],
      sportEvents: [],
      liquidEvents: [],
      waterEvents: [],
    );

    for (var event in calendarEvents.foodEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
        calendarEvent.foodEvents!.add(event);
      }
    }
    for (var event in calendarEvents.sportEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate)) {
        calendarEvent.sportEvents!.add(event);
      }
    }
    // for (var event in calendarEvents.liquidEvents!) {
    //   if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
    //     calendarEvent.liquidEvents!.add(event);
    //   }
    // }
    // for (var event in calendarEvents.waterEvents!) {
    //   if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
    //     calendarEvent.waterEvents!.add(event);
    //   }
    // }

    return joinCalendarEvents(calendarEvent);
  }

  List joinCalendarEvents(CalendarEvents calendarEvents) {
    final list = [];
    list.addAll(calendarEvents.foodEvents!);
    list.addAll(calendarEvents.sportEvents!);
    list.addAll(calendarEvents.liquidEvents!);
    list.addAll(calendarEvents.waterEvents!);
    return list;
  }

  List foundEventsFromGivenDate(DashboardAllCalendarEvents calendarEvents, DateTime date) {
    final calendarEvent = DashboardAllCalendarEvents(
      foodEvents: [],
      sportEvents: [],
      liquidEvents: [],
      waterEvents: [],
      creatineEvent: [],
      collagenEvent: [],
      faecesEvents: [],
      urineEvents: [],
    );

    for (var event in calendarEvents.foodEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
        calendarEvent.foodEvents!.add(event);
      }
    }
    for (var event in calendarEvents.sportEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate)) {
        calendarEvent.sportEvents!.add(event);
      }
    }
    for (var event in calendarEvents.liquidEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
        calendarEvent.liquidEvents!.add(event);
      }
    }
    for (var event in calendarEvents.waterEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventDate!)) {
        calendarEvent.waterEvents!.add(event);
      }
    }
    for (var event in calendarEvents.creatineEvent!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventId!)) {
        calendarEvent.creatineEvent!.add(event);
      }
    }
    for (var event in calendarEvents.collagenEvent!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventId!)) {
        calendarEvent.collagenEvent!.add(event);
      }
    }
    for (var event in calendarEvents.faecesEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventId)) {
        calendarEvent.faecesEvents!.add(event);
      }
    }
    for (var event in calendarEvents.urineEvents!) {
      if (_dateTimeHelper.isSameGivenDateAndMillisecondsDate(date, event.eventId)) {
        calendarEvent.urineEvents!.add(event);
      }
    }

    return joinAllCalendarEvents(calendarEvent);
  }

  List joinAllCalendarEvents(DashboardAllCalendarEvents calendarEvents) {
    final list = [];
    list.addAll(calendarEvents.foodEvents!);
    list.addAll(calendarEvents.sportEvents!);
    list.addAll(calendarEvents.liquidEvents!);
    list.addAll(calendarEvents.waterEvents!);
    list.addAll(calendarEvents.creatineEvent!);
    list.addAll(calendarEvents.collagenEvent!);
    list.addAll(calendarEvents.faecesEvents!);
    list.addAll(calendarEvents.urineEvents!);
    return list;
  }

  static List isEventFoundAgainstDate(List<dynamic> listOfEvents, DateTime date) {
    final list = [];
    for (var event in listOfEvents) {
      if (DateTimeHelper().isSameGivenDateAndMillisecondsDate(date, event.eventId)) {
        list.add(event);
      }
    }
    return list;
  }

  String findFoodNameFromId(int foodId, BuildContext context, List<FoodItemMaster> foodNames) {
    final item = foodNames.firstWhere((foodItemMaster) => foodId == foodItemMaster.id, orElse: FoodItemMaster.empty);
    return item.translate(context);
  }

  /// Resolves the display name for an ingredient. Prefers the inline
  /// name on the ingredient (set for scanned foods that aren't in the
  /// master list) and falls back to a master-list lookup by id.
  String resolveIngredientName(
    FoodInFavorite ingredient,
    BuildContext context,
    List<FoodItemMaster> foodNames,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final inline = locale == 'es' ? ingredient.name_es : ingredient.name_en;
    if (inline != null && inline.isNotEmpty) return inline;
    return findFoodNameFromId(ingredient.id, context, foodNames);
  }

  String findFoodGroup(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    if (foodNames.isNotEmpty) {
      FoodItemMaster foodItem = foodNames.firstWhere(
        (food) {
          if (currentLanguage == 'es') {
            return food.es == foodName;
          } else {
            return food.en == foodName;
          }
        },
        orElse: () => FoodItemMaster.empty(),
      );

      return foodItem.group.orEmpty();
    } else {
      return '';
    }
  }

  FoodInFavorite? findFoodByFoodName(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = foodNames.firstWhere((food) => food.es == foodName);
    } else {
      foodItem = foodNames.firstWhere((food) => food.en == foodName);
    }
      return FoodInFavorite(id: foodItem.id!, qty: 0, unit: -1, conversionFactor: -1, cookingMethod: -1, usedOil: 0);
  }

  FoodInFavorite? findFoodIdToFavorite(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = foodNames.firstWhere((food) => food.es == foodName);
    } else {
      foodItem = foodNames.firstWhere((food) => food.en == foodName);
    }
      return FoodInFavorite(id: foodItem.id!, name_en: foodItem.en.orEmpty(), name_es: foodItem.es.orEmpty(), qty: 0, unit: -1, conversionFactor: 0, cookingMethod: -1, usedOil: 0);
  }

  String findCookingMethodName(BuildContext context, int cookingMethod, List<CookingMethodInfo> cookingMethodsInfo) {
    final cookingMethodInfo = cookingMethodsInfo.firstWhere((cookingMethodInfo) => cookingMethodInfo.id == cookingMethod, orElse: () => CookingMethodInfo());
    if (cookingMethodInfo.id == null) {
      return '';
    } else {
      return cookingMethodInfo.translate(context);
    }
  }

  int? getChosenSportIntensities(String? sportName, SportsInfoMaster sportsInfo, String currentLanguage) {
    if (sportName == null || sportsInfo.sportsInfoMaster.isEmpty) return null;
    final sportChosen = sportsInfo.sportsInfoMaster.orEmpty().firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == sportName;
      } else {
        return sport.en == sportName;
      }
    }, orElse: () => SportInfoMaster.empty());
    return sportChosen.mets;
  }

  int getSportIdByName(String sportName, SportsInfoMaster sportsInfo, String currentLanguage) {
    final sportChosen = sportsInfo.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == sportName;
      } else {
        return sport.en == sportName;
      }
    }, orElse: () => SportInfoMaster.empty());
    return sportChosen.id;
  }

  SportInfoMaster getSportNameById(int? sportId, List<SportInfoMaster> sportsInfoMasterList) {
    return sportsInfoMasterList.firstWhere((sportInfoMaster) => sportInfoMaster.id == sportId, orElse: () => SportInfoMaster.empty());
  }

  UnitInfoMaster findUnitName(int unitId, List<UnitInfoMaster> unitsInfoMaster) {
    final unitInfo = unitsInfoMaster.firstWhere((unitInfo) => unitInfo.id == unitId, orElse: () => UnitInfoMaster.empty(),);
    if (unitInfo.id == 0) {
      return UnitInfoMaster.empty();
    } else {
      return unitInfo;
    }
  }

  double _getFractionToFillWater(double? waterAmount, double totalRequired) {
    if (waterAmount != null) {
      double returnQuantity = waterAmount / totalRequired;
      if (returnQuantity > 1) returnQuantity = 1;
      if (returnQuantity < 0) returnQuantity = 0;
      return double.parse((returnQuantity).toStringAsFixed(2));
    } else {
      return 0.0;
    }
  }

}