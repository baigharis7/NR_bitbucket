import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/local_storage_helper.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

// TODO: ordenar variables y funciones.
// TODO: asegurarme de que va con el async aquí.
class LocalStorageHelperImpl extends LocalStorageHelper {

  Box? _profileBox;
  Box? _foodEvents;

  Future<Box> _openProfileBox() async => openBox(_profileBox, UserProfileEntity.boxName);
  Future<Box> _openFoodEventsBox() async => openBox(_foodEvents, FoodEventEntity.boxName);

  Future<Box> get _getProfileBox async => await _openProfileBox();
  Future<Box> get _getFoodEventsBox async => await _openFoodEventsBox();

  @override
  Future<void> saveProfile(UserProfileEntity profileEntity) async => await _getProfileBox.then((box) => box.put(Constants.PROFILE_ENTITY, profileEntity));

  @override
  Future<void> saveFoodEvent(FoodEventEntity foodEventEntity) async {
    try {
      await foodEventEntity.save();
    } catch (error) {
      try {
        _getFoodEventsBox.then((box) {
          box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
        });
      } catch (error) {
        rethrow;
      }
    }
  }
  @override
  Future<UserProfileEntity> getProfile() async => await _getProfileBox.then((box) => box.get(Constants.PROFILE_ENTITY));

  @override
  Future<List> getAllFoodEvents() async {
    return await _getFoodEventsBox.then((box) {
      return box.values.toList();
    });
  }

  @override
  Future<FoodEventComplete> getLastFoodEvent() async => _getFoodEventsBox.then((box) => box.getAt(box.length - 1));
}