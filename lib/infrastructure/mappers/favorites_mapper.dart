import 'package:nutrenaissance_flutter/data/api/favorites/model/food/upload_food_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/model/liquid/upload_liquid_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/favorites/model/sport/upload_sport_favorite.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';

import '../../domain/models/favorites/sport/add_sport_favorite.dart';

FoodFavorite mapToFoodFavoriteFromEntity(FoodFavoriteEntity foodFavoriteEntity) {
  return FoodFavorite(
    title: foodFavoriteEntity.title,
    eventDate: foodFavoriteEntity.eventDate,
    eventId: foodFavoriteEntity.eventId,
    ingredients: foodFavoriteEntity.ingredients.map((ingredient) => FoodInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavoriteEntity.drinks.map((drink) => FoodInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavoriteEntity.mealTime,
    comment: foodFavoriteEntity.comment,
    dish: foodFavoriteEntity.dish,
    isRoutine: foodFavoriteEntity.isRoutine,
    daysOfWeek: foodFavoriteEntity.daysOfWeek,
    isFavorite: foodFavoriteEntity.isFavorite,
    userId: foodFavoriteEntity.userId,
    time: foodFavoriteEntity.time,
    timeZone: foodFavoriteEntity.timeZone,
  );
}

List<FoodInFavorite> mapToFoodFavoriteList(List<FoodInfo> foodInfoList) {
  return foodInfoList.map((foodInfo) => FoodInFavorite(
      id: foodInfo.id!,
      name_en: foodInfo.name_en.orEmpty(),
      name_es: foodInfo.name_es.orEmpty(),
      qty: foodInfo.eventInfo!.qty!.toInt(),
      unit: foodInfo.eventInfo!.unit!,
      conversionFactor: foodInfo.eventInfo?.conversionFactor,
      usedOil:  foodInfo.eventInfo?.usedOil,
      cookingMethod: foodInfo.eventInfo!.cookingMethod!,
  ),).toList();
}

FoodFavoriteEntity mapToFoodFavoriteEntity(FoodFavorite foodFavorite) {
  return FoodFavoriteEntity(
    userId: foodFavorite.userId,
    title: foodFavorite.title.orEmpty(),
    eventDate: foodFavorite.eventDate.orZero(),
    eventId: foodFavorite.eventId,
    ingredients: foodFavorite.ingredients.map((ingredient) => FoodInFavoriteEntity(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavorite.drinks.map((drink) => FoodInFavoriteEntity(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavorite.mealTime.orZero(),
    comment: foodFavorite.comment,
    dish: foodFavorite.dish,
    isRoutine: foodFavorite.isRoutine,
    isFavorite: foodFavorite.isFavorite,
    time: foodFavorite.time,
    timeZone: foodFavorite.timeZone,
    daysOfWeek: foodFavorite.daysOfWeek,
  );
}

UploadFoodFavorite mapToUploadFoodFavorite(FoodFavorite foodFavorite, String userId,) {
  return UploadFoodFavorite(
    userId: userId,
    eventDate:foodFavorite.eventDate.orZero(),
    title: foodFavorite.title.orEmpty(),
    ingredients: foodFavorite.ingredients.map((ingredient) => UploadFoodInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavorite.drinks.map((drink) => UploadFoodInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavorite.mealTime.orZero(),
    comment: foodFavorite.comment,
    dish: foodFavorite.dish,
    isRoutine: foodFavorite.isRoutine,
    daysOfWeek: foodFavorite.daysOfWeek,
  );
}

SportFavorite mapToSportFavorite(SportEventComplete sportEventComplete) {
  final dateTimeHelper = DateTimeHelper();
  return SportFavorite(
    id: sportEventComplete.info?[0].id,
    minutes: sportEventComplete.info?[0].minutes,
    intensity: sportEventComplete.info?[0].intensity,
    timeStart: dateTimeHelper.formatTimeOfDayToString(sportEventComplete.eventDate),
    eventDate: sportEventComplete.eventDate,
    name_es: sportEventComplete.info?[0].name_es,
    name_en: sportEventComplete.info?[0].name_en,
  );
}

AddSportFavorite mapToSportFavoriteFromRoutine(SportRoutineCompleted sportRoutineCompleted) {
  return AddSportFavorite(
    userId: sportRoutineCompleted.userId,
    eventId: sportRoutineCompleted.eventId,
    eventDate: sportRoutineCompleted.eventDate,
    title: sportRoutineCompleted.sportName,
    info: sportRoutineCompleted.info?.map((e) => AddSportFavInfo(id: e.id?.toInt(), name_en: e.nameEn, name_es: e.nameEs, minutes: e.minutes?.toInt(), timeStart: e.timeStart?.toInt(), intensity: e.intensity?.toInt())).toList(),
    comment: sportRoutineCompleted.comment,
    scheduleTime: sportRoutineCompleted.scheduleTime,
    daysOfWeek: sportRoutineCompleted.daysOfWeek,
    timeZone: sportRoutineCompleted.timeZone,
  );
}

UploadSportFavorite mapToUploadSportFavorite(SportFavorite sportFavorite, String userId) {
  return UploadSportFavorite(
    userId: userId,
    eventDate: sportFavorite.eventDate,
    timeStart: sportFavorite.timeStart,
    intensity: sportFavorite.intensity,
    minutes: sportFavorite.minutes,
    id: sportFavorite.id,
    title: sportFavorite.title,
    comment: sportFavorite.comment,
    name_en: sportFavorite.name_en,
    name_es: sportFavorite.name_es,
  );
}

SportFavoriteEntity mapToSportFavoriteEntity(AddSportFavorite sportFavorite) {
  return SportFavoriteEntity(
    eventId: sportFavorite.eventId,
    eventDate: sportFavorite.eventDate ?? -1,
    userId: sportFavorite.userId.toString(),
    comment: sportFavorite.comment,
    title: sportFavorite.title,
    info: sportFavorite.info?.map((item) => SportFavoriteInfoEntity(id: item.id, intensity: item.intensity, minutes: item.minutes, timeStart: item.timeStart, name_en: item.name_en, name_es: item.name_es)).toList(),
    isFavorite: sportFavorite.isFavorite,
    isCreateRoutine: sportFavorite.isCreateRoutine,
    scheduleTime: sportFavorite.scheduleTime,
    daysOfWeek: sportFavorite.daysOfWeek,
    timeZone: sportFavorite.timeZone,
  );
}

AddSportFavorite mapToSportFavoriteFromEntity(SportFavoriteEntity sportFavoriteEntity) {
  return AddSportFavorite(
    userId: sportFavoriteEntity.userId,
    eventId: sportFavoriteEntity.eventId,
    eventDate: sportFavoriteEntity.eventDate,
    comment: sportFavoriteEntity.comment,
    title: sportFavoriteEntity.title,
    info: sportFavoriteEntity.info?.map((sportItem) => AddSportFavInfo(id: sportItem.id, minutes: sportItem.minutes, intensity: sportItem.intensity, timeStart: sportItem.timeStart, name_en: sportItem.name_en, name_es: sportItem.name_es)).toList(),
    isFavorite: sportFavoriteEntity.isFavorite,
    isCreateRoutine: sportFavoriteEntity.isCreateRoutine,
    scheduleTime: sportFavoriteEntity.scheduleTime,
    daysOfWeek: sportFavoriteEntity.daysOfWeek,
    timeZone: sportFavoriteEntity.scheduleTime,
  );
}

LiquidFavorite mapToLiquidFavoriteFromEntity(LiquidFavoriteEntity liquidFavoriteEntity) {
  return LiquidFavorite(
    title: liquidFavoriteEntity.title,
    eventDate: liquidFavoriteEntity.eventDate,
    ingredients: liquidFavoriteEntity.ingredients.map((ingredient) => LiquidInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, cookingMethod: ingredient.cookingMethod, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: liquidFavoriteEntity.drinks.map((drink) => LiquidInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: liquidFavoriteEntity.mealTime,
    comment: liquidFavoriteEntity.comment,
  );
}

List<LiquidInFavorite> mapToLiquidFavoriteList(List<FoodInfo> liquidInfoList) {
  return liquidInfoList.map((liquidInfo) => LiquidInFavorite(
    id: liquidInfo.id!,
    name_en: liquidInfo.name_en.orEmpty(),
    name_es: liquidInfo.name_es.orEmpty(),
    qty: liquidInfo.eventInfo!.qty!.toInt(),
    unit: liquidInfo.eventInfo!.unit!,
    cookingMethod: liquidInfo.eventInfo!.cookingMethod!,
  ),).toList();
}

LiquidFavoriteEntity mapToLiquidFavoriteEntity(LiquidFavorite liquidFavorite) {
  return LiquidFavoriteEntity(
    title: liquidFavorite.title,
    eventDate: liquidFavorite.eventDate,
    ingredients: liquidFavorite.ingredients.map((ingredient) => LiquidInFavoriteEntity(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, cookingMethod: ingredient.cookingMethod, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: liquidFavorite.drinks.map((drink) => LiquidInFavoriteEntity(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: liquidFavorite.mealTime,
    comment: liquidFavorite.comment,
  );
}

UploadLiquidFavorite mapToUploadLiquidFavorite(LiquidFavorite liquidFavorite, String userId,) {
  return UploadLiquidFavorite(
    userId: userId,
    eventDate:liquidFavorite.eventDate,
    title: liquidFavorite.title,
    ingredients: liquidFavorite.ingredients.map((ingredient) => UploadLiquidInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, cookingMethod: ingredient.cookingMethod, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: liquidFavorite.drinks.map((drink) => UploadLiquidInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: liquidFavorite.mealTime,
    comment: liquidFavorite.comment,
  );
}

FoodFavorite mapToFoodFavoriteFromFoodEvent(FoodEventComplete foodEventComplete) {
  return FoodFavorite(title: foodEventComplete.foodName ?? '',
      eventDate: foodEventComplete.eventDate ?? -1,
      ingredients: foodEventComplete.foodInfo!.map((e) => FoodInFavorite(id: e.id!, name_en: e.name_en!, name_es: e.name_es!, qty: e.eventInfo!.qty!.toInt(), unit: e.eventInfo!.unit!, cookingMethod: e.eventInfo!.cookingMethod!)).toList(),
      drinks: [],
      mealTime: foodEventComplete.mealType ?? -1,
  );
}

FoodFavorite mapToFoodFavoriteFromRoutine(FoodRoutineEvent foodRoutineEvent) {
  return FoodFavorite(
    userId: foodRoutineEvent.userId,
      eventId: foodRoutineEvent.eventId,
      eventDate: foodRoutineEvent.eventDate,
      ingredients: foodRoutineEvent.ingredients.orEmpty().map((routineIngredient) => FoodInFavorite(id: routineIngredient.id, qty: routineIngredient.qty, unit: routineIngredient.unit, conversionFactor: routineIngredient.conversionFactor, cookingMethod: routineIngredient.cookingMethod, usedOil: routineIngredient.usedOil, unitsEquivalences: routineIngredient.unitsEquivalences)).toList(),
      drinks: [],
      mealTime: foodRoutineEvent.mealType,
    title: foodRoutineEvent.foodName,
    comment: foodRoutineEvent.comment,
    time: foodRoutineEvent.time,
    daysOfWeek: foodRoutineEvent.daysOfWeek,
    timeZone: foodRoutineEvent.timeZone,
    dish: foodRoutineEvent.dish,
  );
}

AddSportFavorite mapToSportFavoriteFromEventComplete(
    SportEventComplete sportEventComplete) {
  return AddSportFavorite(
    userId: sportEventComplete.userId,
    eventDate: sportEventComplete.eventDate,
    comment: sportEventComplete.comment,
    title: sportEventComplete.sportName,
    info: sportEventComplete.info
        ?.map(
          (sportItem) => AddSportFavInfo(
        id: sportItem.id,
        minutes: sportItem.minutes,
        intensity: sportItem.intensity,
        timeStart: sportItem.timeStart,
        name_en: sportItem.name_en,
        name_es: sportItem.name_es,
      ),
    )
        .toList(),
  );
}