import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
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
            if (eventInfo.id == Constants.TAP_WATER_ID) {
              amount = amount + ((eventInfo.eventInfo?.qty ?? 0)/1000);
            }
          }
        }
      }

      if (foodEvents.isNotEmpty) {
        for (var foodEvent in foodEvents) {
          for (var eventInfo in foodEvent.foodInfo.orEmpty()) {
            if (eventInfo.id == Constants.TAP_WATER_ID) {
              amount = amount + (((eventInfo.eventInfo?.qty ?? 0) * Constants.DEFAULT_ADD_WATER_QUANTITY));
            }
          }
        }
      }
    if (amount < 0) amount = 0;
    return double.parse(amount.toStringAsFixed(2));
    }
    // else {
    //   return 0.0;
    // }
  // }

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

  String findFoodGroup(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    if (foodNames.isNotEmpty) {
      FoodItemMaster? foodItem = foodNames.firstWhere((food) {
        if (currentLanguage == 'es') {
          return food.es == foodName;
        } else {
          return food.en == foodName;
        }
      });

      return foodItem.group.orEmpty();
    } else {
      return '';
    }
  }

  FoodInEvent? findFoodByFoodName(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = foodNames.firstWhere((food) => food.es == foodName);
    } else {
      foodItem = foodNames.firstWhere((food) => food.en == foodName);
    }
      return FoodInEvent(id: foodItem.id!, qty: 0, unit: -1, cookingMethod: -1);
  }

  FoodInFavorite? findFoodIdToFavorite(String foodName, String currentLanguage, List<FoodItemMaster> foodNames) {
    FoodItemMaster? foodItem;
    if (currentLanguage == 'es') {
      foodItem = foodNames.firstWhere((food) => food.es == foodName);
    } else {
      foodItem = foodNames.firstWhere((food) => food.en == foodName);
    }
      return FoodInFavorite(id: foodItem.id!, name_en: foodItem.en.orEmpty(), name_es: foodItem.es.orEmpty(), qty: 0, unit: -1, cookingMethod: -1);
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
    });
    return sportChosen.mets;
  }

  int getSportIdByName(String sportName, SportsInfoMaster sportsInfo, String currentLanguage) {
    final sportChosen = sportsInfo.sportsInfoMaster.firstWhere((sport) {
      if (currentLanguage == 'es') {
        return sport.es == sportName;
      } else {
        return sport.en == sportName;
      }
    });
    return sportChosen.id;
  }

  SportInfoMaster getSportNameById(int? sportId, List<SportInfoMaster> sportsInfoMasterList) {
    return sportsInfoMasterList.firstWhere((sportInfoMaster) => sportInfoMaster.id == sportId);
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