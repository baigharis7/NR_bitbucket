import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

// TODO: ordenar variables y funciones.
// TODO: asegurarme de que va con el async aquí.
class LocalStorageImpl extends LocalStorageRepository {

  Box? _profileBox;
  Box? _foodEventsBox;
  Box? _masterFilesBox;

  Future<Box> _openProfileBox() async => openBox(_profileBox, UserProfileEntity.boxName);
  Future<Box> _openFoodEventsBox() async => openBox(_foodEventsBox, FoodEventEntity.boxName);
  Future<Box> _openMasterFilesBox() async => openBox(_masterFilesBox, masterFilesBoxName);

  Future<Box> get _getProfileBox async => await _openProfileBox();
  Future<Box> get _getFoodEventsBox async => await _openFoodEventsBox();
  Future<Box> get _getMasterFilesBox async => await _openMasterFilesBox();

  @override
  Future<void> saveProfile(UserProfileEntity profileEntity) async => await _getProfileBox.then((box) => box.put(Constants.PROFILE_ENTITY, profileEntity));

  @override
  Future<void> saveFoodEvent(FoodEventEntity foodEventEntity) async {
    try {
      await foodEventEntity.save();
    } catch (error) {
      try {
        _getFoodEventsBox.then((box) {
          box.add(foodEventEntity);
          //box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
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

  @override
  Future<dynamic> getMasterFile(MasterFilesType masterFileType) async {
    return await _getMasterFilesBox.then((box) {
      return box.get(masterFileType.index);
    });
  }

  @override
  Future<int> getMasterFileVersion(MasterFilesType masterFileType) async {
    final masterFile = await getMasterFile(masterFileType);
    switch (masterFileType) {
      case MasterFilesType.cookingMethods:
        return (masterFile as CookingMethodsEntity).v;
      case MasterFilesType.cookingMethodsInfo:
        return (masterFile as CookingMethodsInfoEntity).v;
      case MasterFilesType.foodAndDrinksNames:
        return (masterFile as FoodsAndDrinksNamesEntity).v;
      case MasterFilesType.nutrientsInfo:
        return (masterFile as NutrientsInfoEntity).v;
      case MasterFilesType.objectivesInfo:
        return (masterFile as ObjectivesInfoEntity).v;
      case MasterFilesType.recommendationGroups:
        return (masterFile as RecommendationGroupsEntity).v;
      default:
        return -1;
    }
  }

  @override
  Future<void> saveMasterFile(int masterFileType, dynamic masterFile) async {
    await _openMasterFilesBox().then((box) {
      box.put(masterFileType, masterFile);
    });
  }

}