import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/api/eventssync/model/events_synchronization_request.dart';
import 'package:nutrenaissance_flutter/data/local/models/analysis/subjective/subjective_analysis_result_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/explainingcards/explaining_card_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodroutines/food_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/liquidevents/liquid_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/cooking_methods_oils_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/nutrients_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/objectives_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/recommendation_groups_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/subjective_analysis_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/supplements_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/modelsappearence/models_appearance_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/recipes/recipe_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/supplement_events_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/watervents/water_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/analysis/subjective/subjective_analysis_result.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
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
  Box? _foodRoutinesBox;
  Box? _liquidEventsBox;
  Box? _waterEventsBox;
  Box? _cookingMethodsBox;
  Box? _cookingMethodsInfoBox;
  Box? _oilTypesBox;
  Box? _conversionFactorsBox;
  Box? _conversionFactorsInfoBox;
  Box? _foodsAndDrinksNamesBox;
  Box? _nutrientsInfoBox;
  Box? _objectivesInfoBox;
  Box? _recommendationGroupsBox;
  Box? _sportsInfoBox;
  Box? _sportEventsBox;
  Box? _sportRoutinesBox;
  Box? _unitsInfoBox;
  Box? _unitsFoodsBox;
  Box? _supplementsInfoBox;
  Box? _supplementEventsBox;
  Box? _supplementFavoritesBox;
  Box? _supplementRoutinesBox;
  Box? _subjectiveAnalysisBox;
  Box? _favoriteFoodsBox;
  Box? _favoriteSportsBox;
  Box? _favoriteLiquidsBox;
  Box? _explainingCardsBox;
  Box? _subjectiveAnalysisResultsBox;
  Box? _userStepsInfoBox;
  Box? _recipeFavoritesBox;
  Box? _fecesEventsBox;
  Box? _urineEventsBox;
  Box? _creatineEventsBox;
  Box? _collagenEventsBox;
  Box? _modelAppearanceBox;
  Box? _cookingMethodsOilsInfoBox;
  Box? _healthSyncMetadataBox;

  Future<Box> _openProfileBox() async => openBox(_profileBox, UserProfileEntity.boxName);
  Future<Box> _openFoodEventsBox() async => openBox(_foodEventsBox, FoodEventEntity.boxName);
  Future<Box> _openFoodRoutinesBox() async => openBox(_foodRoutinesBox, FoodRoutineEntity.boxName);
  Future<Box> _openLiquidEventsBox() async => openBox(_liquidEventsBox, LiquidEventEntity.boxName);
  Future<Box> _openWaterEventsBox() async => openBox(_waterEventsBox, WaterEventEntity.boxName);
  Future<Box> _openMasterFilesBox(MasterFilesType masterFileType) async {
    switch (masterFileType) {
      case MasterFilesType.cookingMethods:
        return openBox(_cookingMethodsBox, cookingMethodsBoxName);
      case MasterFilesType.cookingMethodsInfo:
        return openBox(_cookingMethodsInfoBox, cookingMethodsInfoBoxName);
      case MasterFilesType.oilTypes:
        return openBox(_oilTypesBox, oilTypesBoxName);
      case MasterFilesType.conversionFactors:
        return openBox(_conversionFactorsBox, conversionFactorsBoxName);
      case MasterFilesType.conversionFactorsInfo:
        return openBox(_conversionFactorsInfoBox, conversionFactorsInfoBoxName);
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
      case MasterFilesType.supplementsInfo:
        return openBox(_supplementsInfoBox, supplementsInfoBoxName);
      case MasterFilesType.subjectiveAnalysis:
        return openBox(_subjectiveAnalysisBox, subjectiveAnalysisBoxName);
      case MasterFilesType.cookingMethodsOilsInfo:
        return openBox(_cookingMethodsOilsInfoBox, cookingMethodsOilsInfoBoxName);
    }
  }
  Future<Box> _openSportEventsBox() async => openBox(_sportEventsBox, SportEventEntity.boxName);
  Future<Box> _openSportRoutinesBox() async => openBox(_sportRoutinesBox, SportRoutineEntity.boxName);
  Future<Box> _openFoodFavoritesBox() async => openBox(_favoriteFoodsBox, FoodFavoriteEntity.boxName);
  Future<Box> _openSportFavoritesBox() async => openBox(_favoriteSportsBox, SportFavoriteEntity.boxName);
  Future<Box> _openLiquidFavoritesBox() async => openBox(_favoriteLiquidsBox, LiquidFavoriteEntity.boxName);
  Future<Box> _openSupplementEventsBox() async => openBox(_supplementEventsBox, SupplementEventsEntity.boxName);
  Future<Box> _openSupplementFavoritesBox() async => openBox(_supplementFavoritesBox, SupplementEventsEntity.boxNameFavorites);
  Future<Box> _openSupplementRoutinesBox() async => openBox(_supplementRoutinesBox, SupplementEventsEntity.boxNameRoutines);
  Future<Box> _openExplainingCardsBox() async => openBox(_explainingCardsBox, ExplainingCardEntity.boxName);
  Future<Box> _openSubjectiveAnalysisResultsBox() async => openBox(_subjectiveAnalysisResultsBox, SubjectiveAnalysisResultEntity.boxName);
  Future<Box> _openUserStepsInfoBox() async => openBox(_userStepsInfoBox, StepsEntity.boxName);
  Future<Box> _openRecipeFavoritesBox() async => openBox(_recipeFavoritesBox, RecipeFavoriteEntity.boxName);
  Future<Box> _openFecesEventsBox() async => openBox(_fecesEventsBox, 'feces_events');
  Future<Box> _openUrineEventsBox() async => openBox(_urineEventsBox, 'urine_events');
  Future<Box> _openCreatineEventsBox() async => openBox(_creatineEventsBox, UploadSupplementEventEntity.boxNameCreatine);
  Future<Box> _openCollagenEventsBox() async => openBox(_collagenEventsBox, UploadSupplementEventEntity.boxNameCollagen);
  Future<Box> _openModelAppearanceBox() async => openBox(_modelAppearanceBox, ModelsAppearanceEntity.boxName);

  Future<Box> get _getProfileBox async => await _openProfileBox();
  Future<Box> get _getFoodEventsBox async => await _openFoodEventsBox();
  Future<Box> get _getFoodRoutinesBox async => await _openFoodRoutinesBox();
  Future<Box> get _getLiquidEventsBox async => await _openLiquidEventsBox();
  Future<Box> get _getWaterEventsBox async => await _openWaterEventsBox();
  Future<Box> _getMasterFilesBox(MasterFilesType masterFilesType) async => await _openMasterFilesBox(masterFilesType);
  Future<Box> get _getSportEventsBox async => await _openSportEventsBox();
  Future<Box> get _getSportRoutinesBox async => await _openSportRoutinesBox();
  Future<Box> get _getFoodFavoritesBox async => await _openFoodFavoritesBox();
  Future<Box> get _getSportFavoritesBox async => await _openSportFavoritesBox();
  Future<Box> get _getLiquidFavoritesBox async => await _openLiquidFavoritesBox();
  Future<Box> get _getSupplementEventsBox async => await _openSupplementEventsBox();
  Future<Box> get _getSupplementFavoritesBox async => await _openSupplementFavoritesBox();
  Future<Box> get _getSupplementRoutinesBox async => await _openSupplementRoutinesBox();
  Future<Box> get _getExplainingCardsBox async => await _openExplainingCardsBox();
  Future<Box> get _getSubjectiveAnalysisResultsBox async => await _openSubjectiveAnalysisResultsBox();
  Future<Box> get _getUserStepsInfoBox async => await _openUserStepsInfoBox();
  Future<Box> get _getRecipeFavoritesBox async => await _openRecipeFavoritesBox();
  Future<Box> get _getFecesEventsBox async => await _openFecesEventsBox();
  Future<Box> get _getUrineEventsBox async => await _openUrineEventsBox();
  Future<Box> get _getCreatineEventsBox async => await _openCreatineEventsBox();
  Future<Box> get _getCollagenEventsBox async => await _openCollagenEventsBox();
  Future<Box> get _getModelAppearanceBox async => await _openModelAppearanceBox();

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
        final box = await _getFoodEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as FoodEventEntity).eventId == foodEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, foodEventEntity);
        } else {
          box.add(foodEventEntity);
        }
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
        case MasterFilesType.cookingMethodsOilsInfo:
          return (masterFile as CookingMethodsOilsInfoEntity).v;
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
        final box = await _getSportEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as SportEventEntity).eventId == sportEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, sportEventEntity);
        } else {
          box.add(sportEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getFoodEventsOfToday({DateTime? dateTime}) async {
    List allFoodEvents = await _getFoodEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allFoodEvents.where((foodEvent) => DateTimeHelper.calculateMidNightMillisecondsFromInt(foodEvent.eventDate!) == midnightTime).toList();
  }

  @override
  Future<void> saveLiquidEvent(LiquidEventEntity liquidEventEntity, bool isEdit) async {
    try {
      await liquidEventEntity.save();
    } catch (error) {
      try {
        final box = await _getLiquidEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as LiquidEventEntity).eventDate == liquidEventEntity.eventDate) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, liquidEventEntity);
        } else {
          box.add(liquidEventEntity);
        }
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
  Future<List> getRecentFoodEvents() async {
    List allFoodEvents = await _getFoodEventsBox.then((box) {
      return box.values.toList();
    });

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final recent = allFoodEvents.where((foodEvent) => foodEvent.eventDate! > sevenDaysAgo).toList();
    recent.sort((a, b) => (b.eventDate as int).compareTo(a.eventDate as int));
    return recent;
  }

  @override
  Future<List> getSportsEventsOfToday({DateTime? dateTime}) async {
    List allSportEvents = await _getSportEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allSportEvents.where((sportEvent) => DateTimeHelper.calculateMidNightMillisecondsFromInt(sportEvent.eventDate!) == midnightTime).toList();
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
  Future<List> getRecentSportEvents() async {
    List allSportEvents = await _getSportEventsBox.then((box) {
      return box.values.toList();
    });

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final recent = allSportEvents.where((sportEvent) => sportEvent.eventDate! > sevenDaysAgo).toList();
    recent.sort((a, b) => (b.eventDate as int).compareTo(a.eventDate as int));
    return recent;
  }

  @override
  Future<List> getTodayLiquidEvents({DateTime? dateTime}) async {
    List allLiquidEvents = await _getLiquidEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allLiquidEvents.where((liquidEvent) => DateTimeHelper.calculateMidNightMillisecondsFromInt(liquidEvent.eventDate!) == midnightTime).toList();
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
        final box = await _getWaterEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as WaterEventEntity).eventDate == waterEventEntity.eventDate) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, waterEventEntity);
        } else {
          box.add(waterEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getWaterEventsToday({DateTime? dateTime}) async {
    List allWaterEvents = await _getWaterEventsBox.then((box) {
      return box.values.toList();
    });

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allWaterEvents.where((waterEvent) => DateTimeHelper.calculateMidNightMillisecondsFromInt(waterEvent.eventDate!) == midnightTime).toList();
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
              if ((value as FoodFavoriteEntity).eventId == foodFavoriteEntity.eventId) {
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
            if ((value as FoodFavoriteEntity).eventId == foodFavorite.eventId) {
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
              if ((value as SportFavoriteEntity).eventId == sportFavoriteEntity.eventId) {
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
            if ((value as SportFavoriteEntity).eventId == sportFavorite.eventId) {
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
    foodEventsMap.forEach((key, value) => foodEvents.add((value as FoodEventEntity).eventId!));

    final foodRoutinesMap = await _getFoodRoutinesBox.then((box) => box.toMap());
    final foodRoutines = <int>[];
    foodRoutinesMap.forEach((key, value) => foodRoutines.add((value as FoodRoutineEntity).eventId!));

    final sportEventsMap = await _getSportEventsBox.then((box) => box.toMap());
    final sportEvents = <int>[];
    sportEventsMap.forEach((key, value) => sportEvents.add((value as SportEventEntity).eventId));

    final sportRoutinesMap = await _getSportRoutinesBox.then((box) => box.toMap());
    final sportRoutines = <int>[];
    sportRoutinesMap.forEach((key, value) => sportRoutines.add((value as SportRoutineEntity).eventId!));

    final liquidEventsMap = await _getLiquidEventsBox.then((box) => box.toMap());
    final liquidEvents = <int>[];
    liquidEventsMap.forEach((key, value) => liquidEvents.add((value as LiquidEventEntity).eventDate!));

    final waterEventsMap = await _getWaterEventsBox.then((box) => box.toMap());
    final waterEvents = <int>[];
    waterEventsMap.forEach((key, value) => waterEvents.add((value as WaterEventEntity).eventId!));

    final foodFavoritesMap = await _getFoodFavoritesBox.then((box) => box.toMap());
    final foodFavorites = <int>[];
    foodFavoritesMap.forEach((key, value) => foodFavorites.add((value as FoodFavoriteEntity).eventId!));

    final sportFavoritesMap = await _getSportFavoritesBox.then((box) => box.toMap());
    final sportFavorites = <int>[];
    sportFavoritesMap.forEach((key, value) => sportFavorites.add((value as SportFavoriteEntity).eventId!));

    final liquidFavoritesMap = await _getLiquidFavoritesBox.then((box) => box.toMap());
    final liquidFavorites = <int>[];
    liquidFavoritesMap.forEach((key, value) => liquidFavorites.add((value as LiquidFavoriteEntity).eventDate));

    final subjectiveAnalysisResultsMap = await _getSubjectiveAnalysisResultsBox.then((box) => box.toMap());
    final subjectiveAnalysisResults = <int>[];
    subjectiveAnalysisResultsMap.forEach((key, value) => subjectiveAnalysisResults.add((value as SubjectiveAnalysisResultEntity).eventDate));

    final recipeFavoritesMap = await _getRecipeFavoritesBox.then((box) => box.toMap());
    final recipeFavorites = <int>[];
    recipeFavoritesMap.forEach((key, value) => recipeFavorites.add((value as RecipeFavoriteEntity).eventDate!));

    final fecesEventsMap = await _getFecesEventsBox.then((box) => box.toMap());
    final fecesEvents = <int>[];
    fecesEventsMap.forEach((key, value) => fecesEvents.add((value as UploadFecesEventEntity).eventId));

    final urineEventsMap = await _getUrineEventsBox.then((box) => box.toMap());
    final urineEvents = <int>[];
    urineEventsMap.forEach((key, value) => urineEvents.add((value as UploadFecesEventEntity).eventId));

    final creatineEventsMap = await _getCreatineEventsBox.then((box) => box.toMap());
    final creatineEvents = <int>[];
    creatineEventsMap.forEach((key, value) => creatineEvents.add((value as UploadSupplementEventEntity).eventId!));

    final collagenEventsMap = await _getCollagenEventsBox.then((box) => box.toMap());
    final collagenEvents = <int>[];
    collagenEventsMap.forEach((key, value) => collagenEvents.add((value as UploadSupplementEventEntity).eventId!));

    final supplementEventsMap = await _getSupplementEventsBox.then((box) => box.toMap());
    final supplementEvents = <int>[];
    supplementEventsMap.forEach((key, value) => supplementEvents.add((value as SupplementEventsEntity).eventId));

    final supplementFavoritesMap = await _getSupplementFavoritesBox.then((box) => box.toMap());
    final supplementFavorites = <int>[];
    supplementFavoritesMap.forEach((key, value) => supplementFavorites.add((value as SupplementEventsEntity).eventId));

    final supplementRoutinesMap = await _getSupplementRoutinesBox.then((box) => box.toMap());
    final supplementRoutines = <int>[];
    supplementRoutinesMap.forEach((key, value) => supplementRoutines.add((value as SupplementEventsEntity).eventId));

    return EventsSynchronizationRequest(
      foodEvents: foodEvents,
      foodRoutines: foodRoutines,
      sportEvents: sportEvents,
      sportRoutines: sportRoutines,
      liquidEvents: liquidEvents,
      waterEvents: waterEvents,
      foodFavorites: foodFavorites,
      sportFavorites: sportFavorites,
      liquidFavorites: liquidFavorites,
      subjectiveAnalysis: subjectiveAnalysisResults,
      recipeFavorites: recipeFavorites,
      fecesEvents: fecesEvents,
      urineEvents: urineEvents,
      creatineEvents: creatineEvents,
      collagenEvents: collagenEvents,
      supplementEvents: supplementEvents,
      supplementFavorites: supplementFavorites,
      supplementRoutines: supplementRoutines,
    );
  }

  @override
  Future<List<int>> getAllEventIdsByType(String categoryType) async {
    switch (categoryType) {
      case 'foodEvents':
        final map = await _getFoodEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as FoodEventEntity).eventId!)
            .toList();
      case 'foodRoutines':
        final map = await _getFoodRoutinesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as FoodRoutineEntity).eventId!)
            .toList();
      case 'sportEvents':
        final map = await _getSportEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SportEventEntity).eventId)
            .toList();
      case 'sportRoutines':
        final map = await _getSportRoutinesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SportRoutineEntity).eventId!)
            .toList();
      case 'liquidEvents':
        final map = await _getLiquidEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as LiquidEventEntity).eventDate!)
            .toList();
      case 'waterEvents':
        final map = await _getWaterEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as WaterEventEntity).eventId!)
            .toList();
      case 'foodFavorites':
        final map = await _getFoodFavoritesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as FoodFavoriteEntity).eventId!)
            .toList();
      case 'sportFavorites':
        final map = await _getSportFavoritesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SportFavoriteEntity).eventId!)
            .toList();
      case 'liquidFavorites':
        final map = await _getLiquidFavoritesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as LiquidFavoriteEntity).eventDate)
            .toList();
      case 'subjectiveAnalysis':
        final map = await _getSubjectiveAnalysisResultsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SubjectiveAnalysisResultEntity).eventDate)
            .toList();
      case 'recipeFavorites':
        final map = await _getRecipeFavoritesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as RecipeFavoriteEntity).eventDate!)
            .toList();
      case 'fecesEvents':
        final map = await _getFecesEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as UploadFecesEventEntity).eventId)
            .toList();
      case 'urineEvents':
        final map = await _getUrineEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as UploadFecesEventEntity).eventId)
            .toList();
      case 'creatineEvents':
        final map = await _getCreatineEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as UploadSupplementEventEntity).eventId!)
            .toList();
      case 'collagenEvents':
        final map = await _getCollagenEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as UploadSupplementEventEntity).eventId!)
            .toList();
      case 'supplementEvents':
        final map = await _getSupplementEventsBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SupplementEventsEntity).eventId)
            .toList();
      case 'supplementFavorites':
        final map = await _getSupplementFavoritesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SupplementEventsEntity).eventId)
            .toList();
      case 'supplementRoutines':
        final map = await _getSupplementRoutinesBox.then((box) => box.toMap());
        return map.values
            .map((e) => (e as SupplementEventsEntity).eventId)
            .toList();
      default:
        throw ArgumentError('Invalid category type: $categoryType');
    }
  }

  @override
  Future<bool> eraseDatabaseInformation() async {
    await _clearBox(_getProfileBox);
    await _clearBox(_getFoodEventsBox);
    await _clearBox(_getLiquidEventsBox);
    await _clearBox(_getWaterEventsBox);
    await _clearBox(_getSportEventsBox);
    await _clearBox(_getSportRoutinesBox);
    await _clearBox(_getFoodFavoritesBox);
    await _clearBox(_getSportFavoritesBox);
    await _clearBox(_getLiquidFavoritesBox);
    await _clearBox(_getSupplementEventsBox);
    await _clearBox(_getSupplementFavoritesBox);
    await _clearBox(_getSupplementRoutinesBox);
    await _clearBox(_getSubjectiveAnalysisResultsBox);
    await _clearBox(_getRecipeFavoritesBox);
    await _clearBox(_getFecesEventsBox);
    await _clearBox(_getUrineEventsBox);
    await _clearBox(_getCreatineEventsBox);
    await _clearBox(_getCollagenEventsBox);
    await _clearBox(_getModelAppearanceBox);
    for (var masterFilesType in MasterFilesType.values) {
      await _clearBox(_getMasterFilesBox(masterFilesType));
    }
    return true;
  }

  Future<bool> _clearBox(Future<Box> box) async {
    // Un poco fulera esta implemetación, si no funciona bien hacerlo bien.
    bool res = false;
    res = await box.then((box) {
      box.clear();
      return true ;
    });
    return res;
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
              if ((value as FoodEventEntity).eventId == foodEventEntity.eventId) {
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
            if ((value as SportEventEntity).eventId == sportEventEntity.eventId) {
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

  @override
  Future<List> getSportRoutines() async {
    List allRoutines = await _getSportRoutinesBox.then((box) {
      return box.values.toList();
    });
    return allRoutines;
  }

  @override
  Future<void> saveSportRoutine(SportRoutineEntity sportRoutineEntity, {bool isEdit = false}) async {
    try {
      await sportRoutineEntity.save();
    } catch(error) {
      try {
        final box = await _getSportRoutinesBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as SportRoutineEntity).eventId == sportRoutineEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, sportRoutineEntity);
        } else {
          box.add(sportRoutineEntity);
        }
      } catch(error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeSportRoutines(SportRoutineEntity sportRoutineEntity) async {
    try {
      await sportRoutineEntity.delete();
    } catch (error) {
      try {
        _getSportRoutinesBox.then((box) {
          final sportRoutineMap = box.toMap();
          dynamic desiredKey;
          sportRoutineMap.forEach((key, value) {
            if ((value as SportRoutineEntity).eventId == sportRoutineEntity.eventId) {
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
  Future<void> removeLiquidEvent(LiquidEventEntity liquidEventEntity) async {
    try {
      await liquidEventEntity.delete();
    } catch (error) {
      try {
        _getLiquidEventsBox.then((box) {
          final liquidEventsMap = box.toMap();
          dynamic desiredKey;
          liquidEventsMap.forEach((key, value) {
            if ((value as LiquidEventEntity).eventDate == liquidEventEntity.eventDate) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveRecipeFavorite(RecipeFavoriteEntity recipeFavoriteEntity, {bool isEdit = false}) async {
    try {
      await recipeFavoriteEntity.save();
    } catch(_) {
      try {
        _getRecipeFavoritesBox.then((box) {
          if (isEdit) {
            final recipeFavoritesMap = box.toMap();
            recipeFavoritesMap.forEach((key, value) {
              if ((value as RecipeFavoriteEntity).eventDate == recipeFavoriteEntity.eventDate) {
                box.put(key, recipeFavoriteEntity);
              }
            });
          } else {
            box.add(recipeFavoriteEntity);
          }
        });
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getRecipeFavorites() async {
    List list = await _getRecipeFavoritesBox.then((box) {
      return box.values.toList();
    });

    return list;
  }

  @override
  Future<void> removeRecipeFavorite(RecipeFavoriteEntity recipeFavoriteEntity) async {
    try {
      await recipeFavoriteEntity.delete();
    } catch (error) {
      try {
        _getRecipeFavoritesBox.then((box) {
          final liquidEventsMap = box.toMap();
          dynamic desiredKey;
          liquidEventsMap.forEach((key, value) {
            if ((value as RecipeFavoriteEntity).eventDate == recipeFavoriteEntity.eventDate) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveFecesEvent(UploadFecesEventEntity fecesEventEntity, {bool isEdit = false}) async {
    try {
      await fecesEventEntity.save();
    } catch (error) {
      try {
        final box = await _getFecesEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as UploadFecesEventEntity).eventId == fecesEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, fecesEventEntity);
        } else {
          box.add(fecesEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getFecesEvents() async {
    List list = await _getFecesEventsBox.then((box) {
      return box.values.toList();
    });

    return list;
  }

  @override
  Future<List> getFecesEventsByDate({DateTime? dateTime, DateTime? endDate, int? days}) async {
    List list = await _getFecesEventsBox.then((box) {
      return box.values.toList();
    });

    // Case 1: Days provided (highest priority)
    if (days != null) {
      final end = dateTime ?? DateTime.now();
      final start = end.subtract(Duration(days: days - 1));

      final startMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(start);
      final endMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(end);

      return list.where((element) {
        final eventMidnight = DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId);
        return eventMidnight >= startMidnight && eventMidnight <= endMidnight;
      }).toList();
    }

    // Case 2: No days → fall back to date filters
    if (dateTime != null && endDate != null) {
      final startMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
      final endMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(endDate);

      return list.where((element) {
        final eventMidnight = DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId);
        return eventMidnight >= startMidnight && eventMidnight <= endMidnight;
      }).toList();
    }

    if (dateTime != null) {
      final midnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
      return list.where((element) => DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId) == midnight).toList();
    }

    // Default → today
    final todayMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(DateTime.now());
    return list.where((element) => DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId) == todayMidnight).toList();
  }

  @override
  Future<List> getUrineEventsByDate({DateTime? dateTime, DateTime? endDate, int? days}) async {
    List list = await _getUrineEventsBox.then((box) {
      return box.values.toList();
    });

    // Case 1: Days provided (highest priority)
    if (days != null) {
      final end = dateTime ?? DateTime.now();
      final start = end.subtract(Duration(days: days - 1));

      final startMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(start);
      final endMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(end);

      return list.where((element) {
        final eventMidnight = DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId);
        return eventMidnight >= startMidnight && eventMidnight <= endMidnight;
      }).toList();
    }

    // Case 2: No days → fall back to date filters
    if (dateTime != null && endDate != null) {
      final startMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
      final endMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(endDate);

      return list.where((element) {
        final eventMidnight = DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId);
        return eventMidnight >= startMidnight && eventMidnight <= endMidnight;
      }).toList();
    }

    if (dateTime != null) {
      final midnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
      return list.where((element) => DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId) == midnight).toList();
    }

    // Default → today
    final todayMidnight = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(DateTime.now());
    return list.where((element) => DateTimeHelper.calculateMidNightMillisecondsFromInt(element.eventId) == todayMidnight).toList();
  }

  @override
  Future<List> getUrineEvents() async {
    List list = await _getUrineEventsBox.then((box) {
      return box.values.toList();
    });

    return list;
  }

  @override
  Future<void> saveUrineEvent(UploadFecesEventEntity urineEventEntity, {bool isEdit = false}) async {
    try {
      await urineEventEntity.save();
    } catch (error) {
      try {
        final box = await _getUrineEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as UploadFecesEventEntity).eventId == urineEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, urineEventEntity);
        } else {
          box.add(urineEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeFecesEvent(UploadFecesEventEntity uploadFecesEventEntity) async {
    try {
      await uploadFecesEventEntity.delete();
    } catch (error) {
      try {
        _getFecesEventsBox.then((box) {
          final fecesEventsMap = box.toMap();
          dynamic desiredKey;
          fecesEventsMap.forEach((key, value) {
            if ((value as UploadFecesEventEntity).eventId == uploadFecesEventEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeUrineEvent(UploadFecesEventEntity uploadFecesEventEntity) async {
    try {
      await uploadFecesEventEntity.delete();
    } catch (error) {
      try {
        _getUrineEventsBox.then((box) {
          final urineEventsMap = box.toMap();
          dynamic desiredKey;
          urineEventsMap.forEach((key, value) {
            if ((value as UploadFecesEventEntity).eventId == uploadFecesEventEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveCollagenEvent(UploadSupplementEventEntity supplementCollagenEventEntity, {bool isEdit = false}) async {
    try {
      await supplementCollagenEventEntity.save();
    } catch (error) {
      try {
        final box = await _getCollagenEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as UploadSupplementEventEntity).eventId == supplementCollagenEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, supplementCollagenEventEntity);
        } else {
          box.add(supplementCollagenEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveCreatineEvent(UploadSupplementEventEntity supplementCreatineEventEntity, {bool isEdit = false}) async {
    try {
      await supplementCreatineEventEntity.save();
    } catch (error) {
      try {
        final box = await _getCreatineEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as UploadSupplementEventEntity).eventId == supplementCreatineEventEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, supplementCreatineEventEntity);
        } else {
          box.add(supplementCreatineEventEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<UploadSupplementEventEntity?> getCreatineTodayEvent({DateTime? dateTime}) async {
    List allCreatineEvents = await _getCreatineEventsBox.then((box) {
      return box.values.toList();
    },);

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allCreatineEvents.firstWhere((creatineEntity) => creatineEntity.eventId == midnightTime, orElse: () => null,);
  }

  @override
  Future<UploadSupplementEventEntity?> getCollagenTodayEvent({DateTime? dateTime}) async {
    List allCollagenEvents = await _getCollagenEventsBox.then((box) {
      return box.values.toList();
    },);

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return allCollagenEvents.firstWhere((creatineEntity) => creatineEntity.eventId == midnightTime, orElse: () => null,);
  }

  @override
  Future<List> getAllCreatineEvents() async {
    List allCreatineEvents = await _getCreatineEventsBox.then((box) {
      return box.values.toList();
    },);

    return allCreatineEvents;
  }

  @override
  Future<List> getAllCollagenEvents() async {
    List allCollagenEvents = await _getCollagenEventsBox.then((box) {
      return box.values.toList();
    },);

    return allCollagenEvents;
  }

  @override
  Future<void> saveSupplementEvent(SupplementEventsEntity supplementEventsEntity, {bool isEdit = false}) async {
    try {
      await supplementEventsEntity.save();
    } catch (error) {
      try {
        final box = await _getSupplementEventsBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as SupplementEventsEntity).eventId == supplementEventsEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, supplementEventsEntity);
        } else {
          box.add(supplementEventsEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getSupplementEventsDay({DateTime? dateTime}) async {
    List supplementsEvents = await _getSupplementEventsBox.then((box) {
      return box.values.toList();
    },);

    final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    return supplementsEvents.where((event) => DateTimeHelper.calculateMidNightMillisecondsFromInt(event.eventDate) == midnightTime).toList();
  }

  @override
  Future<List> getAllSupplementEvents() async {
    final box = await _getSupplementEventsBox;
    return box.values.toList();
  }

  @override
  Future<List> getRecentSupplementEvents() async {
    List supplementsEvents = await _getSupplementEventsBox.then((box) {
      return box.values.toList();
    });

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final recent = supplementsEvents.where((event) => event.eventDate > sevenDaysAgo).toList();
    recent.sort((a, b) => (b.eventDate as int).compareTo(a.eventDate as int));
    return recent;
  }

  @override
  Future<void> removeSupplementEvent(SupplementEventsEntity supplementEventsEntity) async {
    try {
      await supplementEventsEntity.delete();
    } catch (error) {
      try {
        _getSupplementEventsBox.then((box) {
          final supplementEventsMap = box.toMap();
          dynamic desiredKey;
          supplementEventsMap.forEach((key, value) {
            if ((value as SupplementEventsEntity).eventId == supplementEventsEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> saveSupplementFavorite(SupplementEventsEntity supplementEventsEntity, {bool isEdit = false}) async {
    try {
      await supplementEventsEntity.save();
    } catch (error) {
      try {
        final box = await _getSupplementFavoritesBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as SupplementEventsEntity).eventId == supplementEventsEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, supplementEventsEntity);
        } else {
          box.add(supplementEventsEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getSupplementFavorites({DateTime? dateTime}) async {
    List supplementsFavorites = await _getSupplementFavoritesBox.then((box) {
      return box.values.toList();
    },);

    // final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    // return supplementsFavorites.where((event) => DateTimeHelper.calculateMidNightMillisecondsFromInt(event.eventDate) == midnightTime).toList();
    return supplementsFavorites;
  }

  @override
  Future<void> saveSupplementRoutine(SupplementEventsEntity supplementRoutineEntity, {bool isEdit = false}) async {
    try {
      await supplementRoutineEntity.save();
    } catch (error) {
      try {
        final box = await _getSupplementRoutinesBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as SupplementEventsEntity).eventId == supplementRoutineEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, supplementRoutineEntity);
        } else {
          box.add(supplementRoutineEntity);
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getSupplementRoutines() async {
    List supplementRoutines = await _getSupplementRoutinesBox.then((box) {
      return box.values.toList();
    },);

    // final midnightTime = dateTime == null ? DateTimeHelper().provideTodayAtMidnightDate().millisecondsSinceEpoch : DateTimeHelper.calculateMidNightMillisecondsFromDateTime(dateTime);
    // return supplementsFavorites.where((event) => DateTimeHelper.calculateMidNightMillisecondsFromInt(event.eventDate) == midnightTime).toList();
    return supplementRoutines;
  }

  @override
  Future<void> removeSupplementRoutine(SupplementEventsEntity supplementEntity) async {
    try {
      await supplementEntity.delete();
    } catch (error) {
      try {
        _getSupplementRoutinesBox.then((box) {
          final supplementRoutinesMap = box.toMap();
          dynamic desiredKey;
          supplementRoutinesMap.forEach((key, value) {
            if ((value as SupplementEventsEntity).eventId == supplementEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeSupplementFavorite(SupplementEventsEntity supplementEntity) async {
    try {
      await supplementEntity.delete();
    } catch (error) {
      try {
        _getSupplementFavoritesBox.then((box) {
          final supplementFavoritesMap = box.toMap();
          dynamic desiredKey;
          supplementFavoritesMap.forEach((key, value) {
            if ((value as SupplementEventsEntity).eventId == supplementEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<bool> eraseDBEventsData() async {
    await _clearBox(_getFoodEventsBox);
    await _clearBox(_getFoodRoutinesBox);
    await _clearBox(_getLiquidEventsBox);
    await _clearBox(_getWaterEventsBox);
    await _clearBox(_getSportEventsBox);
    await _clearBox(_getSportRoutinesBox);
    await _clearBox(_getFoodFavoritesBox);
    await _clearBox(_getSportFavoritesBox);
    await _clearBox(_getLiquidFavoritesBox);
    await _clearBox(_getSupplementEventsBox);
    await _clearBox(_getSupplementFavoritesBox);
    await _clearBox(_getSupplementRoutinesBox);
    await _clearBox(_getSubjectiveAnalysisResultsBox);
    await _clearBox(_getRecipeFavoritesBox);
    await _clearBox(_getFecesEventsBox);
    await _clearBox(_getUrineEventsBox);
    await _clearBox(_getCreatineEventsBox);
    await _clearBox(_getCollagenEventsBox);

    return true;
  }

  @override
  Future<ModelsAppearanceEntity?> showModelAppearance(int modelAppearanceId) async {
    try {
      return _getModelAppearanceBox.then((box) {
        final entity = box.get(modelAppearanceId) as ModelsAppearanceEntity?;
        return entity;
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveModelAppearance(int modelAppearanceId) async {
    try {
      _getModelAppearanceBox.then((box) {
        final entity = box.get(modelAppearanceId) as ModelsAppearanceEntity?;
        if (entity != null) {
          box.put(modelAppearanceId, ModelsAppearanceEntity(id: modelAppearanceId, timeClicked: entity.timeClicked +1, time: DateTime.now().millisecondsSinceEpoch));
        } else {
          box.put(modelAppearanceId, ModelsAppearanceEntity(id: modelAppearanceId, timeClicked: 1, time: DateTime.now().millisecondsSinceEpoch));
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveFoodRoutine(FoodRoutineEntity foodRoutineEntity, {bool isEdit = false}) async {
    try {
      await foodRoutineEntity.save();
    } catch(error) {
      try {
        final box = await _getFoodRoutinesBox;
        dynamic existingKey;
        box.toMap().forEach((key, value) {
          if ((value as FoodRoutineEntity).eventId == foodRoutineEntity.eventId) {
            existingKey = key;
          }
        });
        if (existingKey != null) {
          box.put(existingKey, foodRoutineEntity);
        } else {
          box.add(foodRoutineEntity);
        }
      } catch(error) {
        rethrow;
      }
    }
  }

  @override
  Future<List> getFoodRoutine() async {
    List foodRoutines = await _getFoodRoutinesBox.then((box) {
      return box.values.toList();
    },);

    return foodRoutines;
  }

  @override
  Future<void> removeFoodRoutine(FoodRoutineEntity foodRoutineEntity) async {
    try {
      await foodRoutineEntity.delete();
    } catch (error) {
      try {
        _getFoodRoutinesBox.then((box) {
          final foodRoutineMap = box.toMap();
          dynamic desiredKey;
          foodRoutineMap.forEach((key, value) {
            if ((value as FoodRoutineEntity).eventId == foodRoutineEntity.eventId) {
              desiredKey = key;
            }
          });
          box.delete(desiredKey);
        },);
      } catch (error) {
        rethrow;
      }
    }
  }

  // Health Sync Metadata

  Future<Box> _openHealthSyncMetadataBox() async =>
      openBox(_healthSyncMetadataBox, HealthSyncMetadataEntity.boxName);

  @override
  Future<void> saveHealthSyncMetadata(HealthSyncMetadataEntity metadata) async {
    try {
      final box = await _openHealthSyncMetadataBox();
      await box.put(metadata.healthPlatformId, metadata);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<HealthSyncMetadataEntity>> getHealthSyncMetadata() async {
    final box = await _openHealthSyncMetadataBox();
    return box.values.cast<HealthSyncMetadataEntity>().toList();
  }

  @override
  Future<bool> isHealthActivitySynced(String healthPlatformId) async {
    final box = await _openHealthSyncMetadataBox();
    return box.containsKey(healthPlatformId);
  }

  @override
  Future<void> deleteHealthSyncMetadataBySportEventId(int sportEventId) async {
    final box = await _openHealthSyncMetadataBox();
    final keysToDelete = <String>[];
    for (final entry in box.toMap().entries) {
      final entity = entry.value as HealthSyncMetadataEntity;
      if (entity.sportEventId == sportEventId) {
        keysToDelete.add(entry.key as String);
      }
    }
    await box.deleteAll(keysToDelete);
  }

}