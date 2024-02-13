import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/model/events_synchronization_request.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/explainingcards/explaining_card_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/liquidevents/liquid_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/profile_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/subjective_analysis_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/water_events_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

// TODO: ordenar variables y funciones.
// TODO: asegurarme de que va con el async aquí.
class LocalStorageImpl extends LocalStorageRepository {

  Box? _profileBox;
  Box? _foodEventsBox;
  Box? _liquidEventsBox;
  Box? _waterEventsBox;
  Box? _cookingMethodsBox;
  Box? _cookingMethodsInfoBox;
  Box? _foodsAndDrinksNamesBox;
  Box? _nutrientsInfoBox;
  Box? _objectivesInfoBox;
  Box? _recommendationGroupsBox;
  Box? _sportsInfoBox;
  Box? _sportEventsBox;
  Box? _unitsInfoBox;
  Box? _unitsFoodsBox;
  Box? _subjectiveAnalysisBox;
  Box? _favoriteFoodsBox;
  Box? _favoriteSportsBox;
  Box? _favoriteLiquidsBox;
  Box? _explainingCardsBox;
  Box? _subjectiveAnalysisResultsBox;
  Box? _userStepsInfoBox;

  Future<Box> _openProfileBox() async => openBox(_profileBox, UserProfileEntity.boxName);
  Future<Box> _openFoodEventsBox() async => openBox(_foodEventsBox, FoodEventEntity.boxName);
  Future<Box> _openLiquidEventsBox() async => openBox(_liquidEventsBox, LiquidEventEntity.boxName);
  Future<Box> _openWaterEventsBox() async => openBox(_waterEventsBox, WaterEventEntity.boxName);
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
      case MasterFilesType.unitsInfo:
        return openBox(_unitsInfoBox, unitsInfoBoxName);
      case MasterFilesType.unitsFoods:
        return openBox(_unitsFoodsBox, unitsFoodsBoxName);
      case MasterFilesType.subjectiveAnalysis:
        return openBox(_subjectiveAnalysisBox, subjectiveAnalysisBoxName);
    }
  }
  Future<Box> _openSportEventsBox() async => openBox(_sportEventsBox, SportEventEntity.boxName);
  Future<Box> _openFoodFavoritesBox() async => openBox(_favoriteFoodsBox, FoodFavoriteEntity.boxName);
  Future<Box> _openSportFavoritesBox() async => openBox(_favoriteSportsBox, SportFavoriteEntity.boxName);
  Future<Box> _openLiquidFavoritesBox() async => openBox(_favoriteLiquidsBox, LiquidFavoriteEntity.boxName);
  Future<Box> _openExplainingCardsBox() async => openBox(_explainingCardsBox, ExplainingCardEntity.boxName);
  Future<Box> _openSubjectiveAnalysisResultsBox() async => openBox(_subjectiveAnalysisResultsBox, SubjectiveAnalysisResultEntity.boxName);
  Future<Box> _openUserStepsInfoBox() async => openBox(_userStepsInfoBox, StepsEntity.boxName);

  Future<Box> get _getProfileBox async => await _openProfileBox();
  Future<Box> get _getFoodEventsBox async => await _openFoodEventsBox();
  Future<Box> get _getLiquidEventsBox async => await _openLiquidEventsBox();
  Future<Box> get _getWaterEventsBox async => await _openWaterEventsBox();
  Future<Box> _getMasterFilesBox(MasterFilesType masterFilesType) async => await _openMasterFilesBox(masterFilesType);
  Future<Box> get _getSportEventsBox async => await _openSportEventsBox();
  Future<Box> get _getFoodFavoritesBox async => await _openFoodFavoritesBox();
  Future<Box> get _getSportFavoritesBox async => await _openSportFavoritesBox();
  Future<Box> get _getLiquidFavoritesBox async => await _openLiquidFavoritesBox();
  Future<Box> get _getExplainingCardsBox async => await _openExplainingCardsBox();
  Future<Box> get _getSubjectiveAnalysisResultsBox async => await _openSubjectiveAnalysisResultsBox();
  Future<Box> get _getUserStepsInfoBox async => await _openUserStepsInfoBox();

  @override
  Future<void> saveProfile(UserProfileEntity profileEntity) async {
    return await _getProfileBox.then((box) => box.put(Constants.PROFILE_ENTITY, profileEntity));
  }

  @override
  Future<void> saveFoodEvent(FoodEventEntity foodEventEntity, bool isEdit) async {
    try {
      await foodEventEntity.save();
    } catch (error) {
      try {
        _getFoodEventsBox.then((box) {
          if (isEdit) {
            final foodEventsMap = box.toMap();
            foodEventsMap.forEach((key, value) {
              if ((value as FoodEventEntity).eventDate == foodEventEntity.eventDate) {
                box.put(key, foodEventEntity);
              }
            });
          } else {
            box.add(foodEventEntity);
            //box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
          }
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<UserProfileEntity?> getProfile() async {
    final box = await _getProfileBox;
    return await box.get(Constants.PROFILE_ENTITY);
  }

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
        case MasterFilesType.unitsInfo:
          return (masterFile as UnitsInfoEntity).v;
        case MasterFilesType.unitsFoods:
          return (masterFile as UnitsFoodsEntity).v;
        case MasterFilesType.subjectiveAnalysis:
          return (masterFile as SubjectiveAnalysisListEntity).v;
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
  Future<bool> checkProfileExistence(String userId) async {
    final UserProfileEntity? profile = await getProfile();
    if (profile == null) {
      return false;
    } else {
      if (profile.userId == userId) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Future<List<UserRda>> getUserRdas() async {
    final profileEntity = await getProfile();
    List<UserRda> userRdasEntities = mapToUserProfileModelFromProfileEntity(profileEntity!).userRdas?.userRdas ?? [];
    return userRdasEntities;
  }


  @override
  Future<void> saveSportEvent(SportEventEntity sportEventEntity, bool isEdit) async {
    try {
      await sportEventEntity.save();
    } catch (error) {
      try {
        _getSportEventsBox.then((box) {
          if (isEdit) {
            final sportEventsMap = box.toMap();
            sportEventsMap.forEach((key, value) {
              if ((value as SportEventEntity).eventDate == sportEventEntity.eventDate) {
                box.put(key, sportEventEntity);
              }
            });
          } else {
            box.add(sportEventEntity);
            // box.put(sportEventEntity.eventDate.getHiveKey(), sportEventEntity);
          }
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getFoodEventsOfToday() async {
    List allFoodEvents = await _getFoodEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    return allFoodEvents.where((foodEvent) => foodEvent.eventDate! > midnightTime).toList();
  }

  @override
  Future<void> saveLiquidEvent(LiquidEventEntity liquidEventEntity, bool isEdit) async {
    try {
      await liquidEventEntity.save();
    } catch (error) {
      try {
        _getLiquidEventsBox.then((box) {
          if (isEdit) {
            final liquidEventsMap = box.toMap();
            liquidEventsMap.forEach((key, value) {
              if ((value as LiquidEventEntity).eventDate == liquidEventEntity.eventDate) {
                box.put(key, liquidEventEntity);
              }
            });
          } else {
            box.add(liquidEventEntity);
            //box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
          }
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getWeekFoodEvents() async {
    List allFoodEvents = await _getFoodEventsBox.then((box) {
      return box.values.toList();
    });

    final mondayMidnightTime = DateTimeHelper().provideMondayAtMidnightDate().millisecondsSinceEpoch;
    return allFoodEvents.where((foodEvent) => foodEvent.eventDate! > mondayMidnightTime).toList();
  }

  @override
  Future<List> getSportsEventsOfToday() async {
    List allSportEvents = await _getSportEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    return allSportEvents.where((sportEvent) => sportEvent.eventDate! > midnightTime).toList();
  }

  @override
  Future<List> getWeeklySportEvents() async {
    List allSportEvents = await _getSportEventsBox.then((box) {
      return box.values.toList();
    });

    final mondayMidnightTime = DateTimeHelper().provideMondayAtMidnightDate().millisecondsSinceEpoch;
    return allSportEvents.where((sportEvent) => sportEvent.eventDate! > mondayMidnightTime).toList();
  }

  @override
  Future<List> getTodayLiquidEvents() async {
    List allLiquidEvents = await _getLiquidEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    return allLiquidEvents.where((liquidEvent) => liquidEvent.eventDate! > midnightTime).toList();
  }

  @override
  Future<List> getWeeklyLiquidEvents() async {
    List allLiquidEvents = await _getLiquidEventsBox.then((box) {
      return box.values.toList();
    });

    final mondayMidnightTime = DateTimeHelper().provideMondayAtMidnightDate().millisecondsSinceEpoch;
    return allLiquidEvents.where((liquidEvent) => liquidEvent.eventDate! > mondayMidnightTime).toList();
  }

  @override
  Future<void> saveWaterEvent(WaterEventMaster waterEventMaster) async {
    final waterEventEntity = mapToWaterEventEntity(waterEventMaster);
    try {
      await waterEventEntity.save();
    } catch (error) {
      try {
        _getWaterEventsBox.then((box) {
          box.add(waterEventEntity);
          //box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getWaterEventsToday() async {
    List allWaterEvents = await _getWaterEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    return allWaterEvents.where((waterEvent) => waterEvent.eventDate! > midnightTime).toList();
  }

  @override
  Future<List> getAllSportEvents() async {
    List allSportEvents = await _getSportEventsBox.then((box) {
      return box.values.toList();
    });

    return allSportEvents;
  }

  @override
  Future<List> getAllLiquidEvents() async {
    List allLiquidEvents = await _getLiquidEventsBox.then((box) {
      return box.values.toList();
    });

    return allLiquidEvents;
  }

  @override
  Future<List> getAllWaterEvents() async {
    List allWaterEvents = await _getWaterEventsBox.then((box) {
      return box.values.toList();
    });

    return allWaterEvents;
  }

  @override
  Future<List> getFoodFavorites() async {
    List foodFavorites = await _getFoodFavoritesBox.then((box) {
      return box.values.toList();
    });

    return foodFavorites;
  }

  @override
  Future<void> saveFoodFavorite(FoodFavorite foodFavorite, {bool? isEdit = false}) async {
    final foodFavoriteEntity = mapToFoodFavoriteEntity(foodFavorite);
    try {
      await foodFavoriteEntity.save();
    } catch (error) {
      try {
        _getFoodFavoritesBox.then((box) {
          if (isEdit != null && isEdit) {
            final foodFavoritesMap = box.toMap();
            foodFavoritesMap.forEach((key, value) {
              if ((value as FoodFavoriteEntity).eventDate == foodFavoriteEntity.eventDate) {
                box.put(key, foodFavoriteEntity);
              }
            });
          } else {
            box.add(foodFavoriteEntity);
          }
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeFoodFavorite(FoodFavorite foodFavorite) async {
    final foodFavoriteEntity = mapToFoodFavoriteEntity(foodFavorite);

    try {
      await foodFavoriteEntity.delete();
    } catch (error) {
      try {
        _getFoodFavoritesBox.then((box) {
          final favoritesMap = box.toMap();
          favoritesMap.forEach((key, value){
            if ((value as FoodFavoriteEntity).eventDate == foodFavorite.eventDate) {
              box.delete(key);
            }
          });
          // dynamic desiredKey;
          // favoritesMap.forEach((key, value){
          //   if ((value as FoodFavoriteEntity).eventDate == foodFavorite.eventDate) {
          //     desiredKey = key;
          //   }
          // });
          // box.delete(desiredKey);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<bool> saveSportFavorite(AddSportFavorite sportFavorite, {bool isEdit = false}) async {
    final sportFavoriteEntity = mapToSportFavoriteEntity(sportFavorite);
    try {
      await sportFavoriteEntity.save();
      return true;
    } catch (error) {
      try {
        _getSportFavoritesBox.then((box) {
          if (isEdit) {
            final sportFavoritesMap = box.toMap();
            sportFavoritesMap.forEach((key, value) {
              if ((value as SportFavoriteEntity).eventDate == sportFavoriteEntity.eventDate) {
                box.put(key, sportFavoriteEntity);
              }
            });
          } else {
            box.add(sportFavoriteEntity);
          }
        });
        return true;
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getSportFavorites() async {
    List sportFavorites = await _getSportFavoritesBox.then((box) {
      return box.values.toList();
    });

    return sportFavorites;
  }

  @override
  Future<void> removeSportFavorite(AddSportFavorite sportFavorite) async {
    final sportFavoriteEntity = mapToSportFavoriteEntity(sportFavorite);

    try {
      await sportFavoriteEntity.delete();
    } catch (error) {
      try {
        _getSportFavoritesBox.then((box) {
          final favoritesMap = box.toMap();
          dynamic desiredKey;
          favoritesMap.forEach((key, value){
            if ((value as SportFavoriteEntity).eventDate == sportFavorite.eventDate) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getLiquidFavorites() async {
    List foodFavorites = await _getFoodFavoritesBox.then((box) {
      return box.values.toList();
    });

    return foodFavorites;
  }

  @override
  Future<void> removeLiquidFavorite(LiquidFavorite liquidFavorite) async {
    final foodFavoriteEntity = mapToLiquidFavoriteEntity(liquidFavorite);
    try {
      await foodFavoriteEntity.save();
    } catch (error) {
      try {
        _getFoodFavoritesBox.then((box) {
          box.add(foodFavoriteEntity);
          //box.put(foodEventEntity.eventDate.getHiveKey(), foodEventEntity);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveLiquidFavorite(LiquidFavorite liquidFavorite) async {
    final liquidFavoriteEntity = mapToLiquidFavoriteEntity(liquidFavorite);

    try {
      await liquidFavoriteEntity.delete();
    } catch (error) {
      try {
        _getLiquidFavoritesBox.then((box) {
          final favoritesMap = box.toMap();
          dynamic desiredKey;
          favoritesMap.forEach((key, value){
            if ((value as LiquidFavoriteEntity).eventDate == liquidFavorite.eventDate) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveExplainingCardInteraction(int explainingCardId) async {
    try {
      _getExplainingCardsBox.then((box) {
        final entity = box.get(explainingCardId) as ExplainingCardEntity?;
        if (entity != null) {
          box.put(explainingCardId, ExplainingCardEntity(id: explainingCardId, timesClicked: entity.timesClicked +1));
        } else {
          box.put(explainingCardId, ExplainingCardEntity(id: explainingCardId, timesClicked: 1));
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> isNecessaryToShowExplainingCard(int explainingCardId) async {
    try {
      return _getExplainingCardsBox.then((box) {
        final entity = box.get(explainingCardId) as ExplainingCardEntity?;
        if (entity != null) {
          return entity.timesClicked < 1;
        } else {
          return true;
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<EventsSynchronizationRequest> getAllEventIds() async {
    final foodEventsMap = await _getFoodEventsBox.then((box) => box.toMap());
    final foodEvents = <int>[];
    foodEventsMap.forEach((key, value) => foodEvents.add((value as FoodEventEntity).eventDate!));

    final sportEventsMap = await _getSportEventsBox.then((box) => box.toMap());
    final sportEvents = <int>[];
    sportEventsMap.forEach((key, value) => sportEvents.add((value as SportEventEntity).eventDate));

    final liquidEventsMap = await _getLiquidEventsBox.then((box) => box.toMap());
    final liquidEvents = <int>[];
    liquidEventsMap.forEach((key, value) => liquidEvents.add((value as LiquidEventEntity).eventDate!));

    final waterEventsMap = await _getWaterEventsBox.then((box) => box.toMap());
    final waterEvents = <int>[];
    waterEventsMap.forEach((key, value) => waterEvents.add((value as WaterEventEntity).eventDate!));

    final foodFavoritesMap = await _getFoodFavoritesBox.then((box) => box.toMap());
    final foodFavorites = <int>[];
    foodFavoritesMap.forEach((key, value) => foodFavorites.add((value as FoodFavoriteEntity).eventDate));

    final sportFavoritesMap = await _getSportFavoritesBox.then((box) => box.toMap());
    final sportFavorites = <int>[];
    sportFavoritesMap.forEach((key, value) => sportFavorites.add((value as SportFavoriteEntity).eventDate));

    final liquidFavoritesMap = await _getLiquidFavoritesBox.then((box) => box.toMap());
    final liquidFavorites = <int>[];
    liquidFavoritesMap.forEach((key, value) => liquidFavorites.add((value as LiquidFavoriteEntity).eventDate));

    final subjectiveAnalysisResultsMap = await _getSubjectiveAnalysisResultsBox.then((box) => box.toMap());
    final subjectiveAnalysisResults = <int>[];
    subjectiveAnalysisResultsMap.forEach((key, value) => subjectiveAnalysisResults.add((value as SubjectiveAnalysisResultEntity).eventDate));

    return EventsSynchronizationRequest(
      foodEvents: foodEvents,
      sportEvents: sportEvents,
      liquidEvents: liquidEvents,
      waterEvents: waterEvents,
      foodFavorites: foodFavorites,
      sportFavorites: sportFavorites,
      liquidFavorites: liquidFavorites,
      subjectiveAnalysis: subjectiveAnalysisResults,
    );
  }

  @override
  Future<bool> eraseDatabaseInformation() async {
    await _clearBox(_getProfileBox);
    await _clearBox(_getFoodEventsBox);
    await _clearBox(_getLiquidEventsBox);
    await _clearBox(_getWaterEventsBox);
    await _clearBox(_getSportEventsBox);
    await _clearBox(_getFoodFavoritesBox);
    await _clearBox(_getSportFavoritesBox);
    await _clearBox(_getLiquidFavoritesBox);
    await _clearBox(_getSubjectiveAnalysisResultsBox);
    return true;
  }

  Future<bool> _clearBox(Future<Box> box) async {
    // Un poco fulera esta implemetación, si no funciona bien hacerlo bien.
    await box.then((box) {
      box.clear();
      return true;
    });
    return false;
  }

  @override
  Future<bool> saveSubjectiveAnalysis(SubjectiveAnalysisResult subjectiveAnalysis) async {
    final subjectiveAnalysisResultsEntity = mapToSubjectiveAnalysisResultsEntity(subjectiveAnalysis);
    try {
      await subjectiveAnalysisResultsEntity.save();
      return true;
    } catch (error) {
      try {
        _getSubjectiveAnalysisResultsBox.then((box) {
          box.add(subjectiveAnalysisResultsEntity);
        });
        return true;
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeFoodEvent(FoodEventComplete foodEventComplete) async {
    var foodEventEntity = FoodEventEntity(foodEventComplete.userId, foodEventComplete.eventDate, foodEventComplete.eventId, foodEventComplete.mealType, foodEventComplete.foodName, foodEventComplete.comment, [], foodEventComplete.dish, foodEventComplete.eventKcals);
    try {
      await foodEventEntity.delete();
    } catch (error) {
      try {
        _getFoodEventsBox.then((box) {
            final foodEventsMap = box.toMap();
            dynamic desiredKey;
            foodEventsMap.forEach((key, value) {
              if ((value as FoodEventEntity).eventDate == foodEventEntity.eventDate) {
                desiredKey = key;
              }
            });
            box.delete(desiredKey);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeSportEvent(SportEventComplete sportEventComplete) async {
    final sportEventEntity = mapToSportEventEntity(sportEventComplete);
    try {
      await sportEventEntity.delete();
    } catch (error) {
      try {
        _getSportEventsBox.then((box) {
          final sportEventsMap = box.toMap();
          dynamic desiredKey;
          sportEventsMap.forEach((key, value) {
            if ((value as SportEventEntity).eventDate == sportEventEntity.eventDate) {
              desiredKey = key;
            }
          });
         box.delete(desiredKey);
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveSteps(StepsEntity stepsEntity, {bool? isEdit = false}) async {
    try {
      await stepsEntity.save();
    } catch(error) {
      try {
        _getUserStepsInfoBox.then((box) {
            final stepEventsMap = box.toMap();
            if (stepEventsMap.isNotEmpty) {
              stepEventsMap.forEach((key, value) {
                if ((value as StepsEntity).eventId == stepsEntity.eventId) {
                  box.put(key, stepsEntity);
                } else {
                  box.add(stepsEntity);
                }
              });
            } else {
              box.add(stepsEntity);
            }
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getTodaySteps() async {
    List allStepEvents = await _getUserStepsInfoBox.then((box) {
      return box.values.toList();
    },);

    // final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    // return allStepEvents.where((stepEvent) => stepEvent.eventId! > midnightTime).toList();
    return allStepEvents;
  }

  @override
  Future<StepsEntity> getTodayStep() async {
    List allStepEvents = await _getUserStepsInfoBox.then((box) {
      return box.values.toList();
    },);

    final midnightTime = DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch;
    return allStepEvents.firstWhere((stepEvent) => stepEvent.eventId == midnightTime, orElse: () => StepsEntity(eventId: null, initialSteps:  null, actualSteps:  null));
  }

}