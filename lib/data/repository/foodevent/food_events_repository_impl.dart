import 'package:nutrenaissance_flutter/data/api/foodevents/food_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodevents/food_events_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

class FoodEventsRepositoryImpl extends FoodEventsRepository {
  final LocalStorageRepository localStorageRepository;
  final FoodEventsApi foodEventsApi;

  FoodEventsRepositoryImpl({required this.localStorageRepository, required this.foodEventsApi});

  @override
  Future<void> saveFoodEvent(UploadFoodEvent uploadFoodEvent) async {
    final foodEventEntity = mapToFoodEventEntity(uploadFoodEvent);
    localStorageRepository.saveFoodEvent(foodEventEntity);
  }

  @override
  Future<UploadFoodEvent> uploadFoodEvent(FoodEventSimple foodEventSimple) async => UploadFoodEvent.fromJson(await foodEventsApi.uploadFoodEvent(foodEventSimple));

  @override
  Future<List<FoodEventComplete>> getAllFoodEvents() async {
    final List allEvents = await localStorageRepository.getAllFoodEvents();
    return mapToFoodEventCompleteList(allEvents);
  }

  @override
  Future<FoodEventComplete> getLastFoodEvent() => localStorageRepository.getLastFoodEvent();

}