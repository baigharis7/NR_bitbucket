import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

class FoodEventsRepositoryImpl extends FoodEventsRepository {
  final LocalStorageRepository localStorageRepository;
  final FoodEventsApi foodEventsApi;

  FoodEventsRepositoryImpl({required this.localStorageRepository, required this.foodEventsApi});

  @override
  Future<void> saveFoodEvent(UploadFoodEvent uploadFoodEvent, bool isEdit) async {
    final foodEventEntity = mapToFoodEventEntity(uploadFoodEvent);
    localStorageRepository.saveFoodEvent(foodEventEntity, isEdit);
  }

  @override
  Future<UploadFoodEvent> uploadFoodEvent(FoodEventSimple foodEventSimple) async {

    final ingredients = foodEventSimple.ingredients!.map((ingredient) =>
        FoodInEvent(
            id: ingredient.id,
            qty: getQuantityWithOtherUnits(
                ingredient.qty,
                ingredient.unit,
                ingredient.unitsEquivalences.orEmpty(),
            ),
            unit: ingredient.unit,
            conversionFactor: ingredient.conversionFactor,
            cookingMethod: ingredient.cookingMethod,
          usedOil: ingredient.usedOil,
        ),
    );

    foodEventSimple.ingredients = ingredients.toList();

    final foodEvent = await foodEventsApi.uploadFoodEvent(foodEventSimple);
    return UploadFoodEvent.fromJson(foodEvent);
  }

  @override
  Future<List<FoodEventComplete>> getAllFoodEvents() async {
    final List allEvents = await localStorageRepository.getAllFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<FoodEventComplete> getLastFoodEvent() => localStorageRepository.getLastFoodEvent();

  @override
  Future<List<FoodEventComplete>> getFoodEventsOfToday({DateTime? dateTime}) async {
    final List allEvents = await localStorageRepository.getFoodEventsOfToday(dateTime: dateTime);
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<List<FoodEventComplete>> getWeekFoodEvents() async {
    final List allEvents = await localStorageRepository.getWeekFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<bool> removeFoodEvent(FoodEventComplete foodEventComplete) async {
    try {
      final removeFoodEvent = await localStorageRepository.removeFoodEvent(foodEventComplete);
      return true;
    } catch (_) {
      throw false;
    }
  }

  @override
  Future<bool> deleteFoodEvent(String userId, int eventDate) async {
    try {
      await foodEventsApi.deleteFoodEvent(userId, eventDate);
      return true;
    } catch (_) {
      return false;
    }
  }
}