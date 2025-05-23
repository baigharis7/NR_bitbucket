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
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';

import '../../domain/models/favorites/sport/add_sport_favorite.dart';

FoodFavorite mapToFoodFavoriteFromEntity(FoodFavoriteEntity foodFavoriteEntity) {
  return FoodFavorite(
    title: foodFavoriteEntity.title,
    eventDate: foodFavoriteEntity.eventDate,
    ingredients: foodFavoriteEntity.ingredients.map((ingredient) => FoodInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavoriteEntity.drinks.map((drink) => FoodInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavoriteEntity.mealTime,
    comment: foodFavoriteEntity.comment,
    dish: foodFavoriteEntity.dish,
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
    title: foodFavorite.title,
    eventDate: foodFavorite.eventDate,
    ingredients: foodFavorite.ingredients.map((ingredient) => FoodInFavoriteEntity(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavorite.drinks.map((drink) => FoodInFavoriteEntity(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavorite.mealTime,
    comment: foodFavorite.comment,
    dish: foodFavorite.dish,
  );
}

UploadFoodFavorite mapToUploadFoodFavorite(FoodFavorite foodFavorite, String userId,) {
  return UploadFoodFavorite(
    userId: userId,
    eventDate:foodFavorite.eventDate,
    title: foodFavorite.title,
    ingredients: foodFavorite.ingredients.map((ingredient) => UploadFoodInFavorite(id: ingredient.id, name_en: ingredient.name_en.orEmpty(), name_es: ingredient.name_es.orEmpty(), qty: ingredient.qty, unit: ingredient.unit, conversionFactor: ingredient.conversionFactor, cookingMethod: ingredient.cookingMethod, usedOil: ingredient.usedOil, unitsEquivalences: ingredient.unitsEquivalences)).toList(),
    drinks: foodFavorite.drinks.map((drink) => UploadFoodInFavorite(id: drink.id, name_en: drink.name_en.orEmpty(), name_es: drink.name_es.orEmpty(), qty: drink.qty, unit: drink.unit, cookingMethod: drink.cookingMethod, unitsEquivalences: drink.unitsEquivalences)).toList(),
    mealTime: foodFavorite.mealTime,
    comment: foodFavorite.comment,
    dish: foodFavorite.dish,
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
    eventDate: sportRoutineCompleted.eventId,
    title: sportRoutineCompleted.sportName,
    info: sportRoutineCompleted.info?.map((e) => AddSportFavInfo(id: e.id?.toInt(), name_en: e.nameEn, name_es: e.nameEs, minutes: e.minutes?.toInt(), timeStart: e.timeStart?.toInt(), intensity: e.intensity?.toInt())).toList(),
    routineTime: sportRoutineCompleted.routineTime,
    comment: sportRoutineCompleted.comment,
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
    eventDate: sportFavorite.eventDate ?? -1,
    userId: sportFavorite.userId.toString(),
    comment: sportFavorite.comment,
    title: sportFavorite.title,
    info: sportFavorite.info?.map((item) => SportFavoriteInfoEntity(id: item.id, intensity: item.intensity, minutes: item.minutes, timeStart: item.timeStart, name_en: item.name_en, name_es: item.name_es)).toList(),
    routineTime: sportFavorite.routineTime,
  );
}

AddSportFavorite mapToSportFavoriteFromEntity(SportFavoriteEntity sportFavoriteEntity) {
  final dateTimeHelper = DateTimeHelper();
  return AddSportFavorite(
    userId: sportFavoriteEntity.userId,
    eventDate: sportFavoriteEntity.eventDate,
    comment: sportFavoriteEntity.comment,
    title: sportFavoriteEntity.title,
    info: sportFavoriteEntity.info?.map((sportItem) => AddSportFavInfo(id: sportItem.id, minutes: sportItem.minutes, intensity: sportItem.intensity, timeStart: sportItem.timeStart, name_en: sportItem.name_en, name_es: sportItem.name_es)).toList(),
    routineTime: sportFavoriteEntity.routineTime,
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