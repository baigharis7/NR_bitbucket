import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_rdas_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/user_rdas_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

// TODO: ordenar variables y funciones.
// TODO: asegurarme de que va con el async aquí.
class LocalStorageImpl extends LocalStorageRepository {

  Box? _profileBox;
  Box? _foodEventsBox;
  Box? _cookingMethodsBox;
  Box? _cookingMethodsInfoBox;
  Box? _foodsAndDrinksNamesBox;
  Box? _nutrientsInfoBox;
  Box? _objectivesInfoBox;
  Box? _recommendationGroupsBox;
  Box? _userRdasBox;
  Box? _sportsInfoBox;
  Box? _sportEventsBox;

  Future<Box> _openProfileBox() async => openBox(_profileBox, UserProfileEntity.boxName);
  Future<Box> _openFoodEventsBox() async => openBox(_foodEventsBox, FoodEventEntity.boxName);
  Future<Box> _openMasterFilesBox(MasterFilesType masterFileType) async {
    switch (masterFileType) {
      case MasterFilesType.cookingMethods:
        return openBox(_cookingMethodsBox, cookingMethodsBoxName);
      case MasterFilesType.cookingMethodsInfo:
        return openBox(_cookingMethodsInfoBox, cookingMethodsInfoBoxName);
      case MasterFilesType.foodsAndDrinksNames:
        return openBox(_foodsAndDrinksNamesBox, foodsAndDrinksNamesBoxName);
      case MasterFilesType.nutrientsInfo:
        return openBox(_nutrientsInfoBox, nutrientsInfoBoxName);
      case MasterFilesType.objectivesInfo:
        return openBox(_objectivesInfoBox, objectivesInfoBoxName);
      case MasterFilesType.recommendationGroups:
        return openBox(_recommendationGroupsBox, recommendationGroupsBoxName);
      case MasterFilesType.sportsInfo:
        return openBox(_sportsInfoBox, sportsInfoBoxName);
    }
  }
  Future<Box> _openUserRdasBox() async => openBox(_userRdasBox, UserRdasEntity.boxName);
  Future<Box> _openSportEventsBox() async => openBox(_sportEventsBox, SportEventEntity.boxName);


  Future<Box> get _getProfileBox async => await _openProfileBox();
  Future<Box> get _getFoodEventsBox async => await _openFoodEventsBox();
  Future<Box> get _getUserRdasBox async => await _openUserRdasBox();
  Future<Box> _getMasterFilesBox(MasterFilesType masterFilesType) async => await _openMasterFilesBox(masterFilesType);
  Future<Box> get _getSportEventsBox async => await _openSportEventsBox();

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
  Future<UserProfileEntity?> getProfile() async => await _getProfileBox.then((box) => box.get(Constants.PROFILE_ENTITY));

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
    return await _getMasterFilesBox(masterFileType).then((box) {
      return box.get(masterFileType.index);
    });
  }

  @override
  Future<int> getMasterFileVersion(MasterFilesType masterFileType) async {
    try {
      final masterFile = await getMasterFile(masterFileType);
      if (masterFile == null) return -1;
      switch (masterFileType) {
        case MasterFilesType.cookingMethods:
          return (masterFile as CookingMethodsEntity).v;
        case MasterFilesType.cookingMethodsInfo:
          return (masterFile as CookingMethodsInfoEntity).v;
        case MasterFilesType.foodsAndDrinksNames:
          return (masterFile as FoodsAndDrinksNamesEntity).v;
        case MasterFilesType.nutrientsInfo:
          return (masterFile as NutrientsInfoEntity).v;
        case MasterFilesType.objectivesInfo:
          return (masterFile as ObjectivesInfoEntity).v;
        case MasterFilesType.recommendationGroups:
          return (masterFile as RecommendationGroupsEntity).v;
        case MasterFilesType.sportsInfo:
          return (masterFile as SportsInfoEntity).v;
        default:
          return -1;
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveMasterFile(MasterFilesType masterFileType, dynamic masterFile) async {
    await _openMasterFilesBox(masterFileType).then((box) {
      box.put(masterFileType.index, masterFile);
    });
  }

  @override
  Future<bool> checkProfileExistence() async {
    final UserProfileEntity? profile = await getProfile();
    if (profile == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<List<UserRdas>> getUserRdas() async {
    final List<dynamic> userRdasEntities = await _getUserRdasBox.then((box) => box.get(Constants.USER_RDAS_ENTITY));
    return mapToUserRdas(userRdasEntities);
  }

  @override
  Future<void> saveUserRdas(List<UserRdasResponse> userRdas) async => await _openUserRdasBox().then((box) =>
      box.put(Constants.USER_RDAS_ENTITY, mapToUserRdasEntity(userRdas))
  );

  @override
  Future<void> saveSportEvent(SportEventEntity sportEventEntity) async {
    try {
      await sportEventEntity.save();
    } catch (error) {
      try {
        _getSportEventsBox.then((box) {
          box.add(sportEventEntity);
          // box.put(sportEventEntity.eventDate.getHiveKey(), sportEventEntity);
        });
      } catch (error) {
        rethrow;
      }
    }
  }
}