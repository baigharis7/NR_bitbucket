import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

abstract class LocalStorageHelper {

  Future<UserProfileEntity> getProfile();
  Future<List> getAllFoodEvents();
  Future<FoodEventComplete> getLastFoodEvent();
  Future<void> saveProfile(UserProfileEntity profileEntity);
  Future<void> saveFoodEvent(FoodEventEntity foodEventEntity);
  Future<void> saveMasterFile(int masterFileType, dynamic masterFile);
  Future<dynamic> getMasterFile(MasterFilesType masterFileType);
  Future<int> getMasterFileVersion(MasterFilesType masterFileType);
  Future<Box> openBox(Box? box, String boxName) async {
    if (box == null || !box.isOpen) box = await Hive.openBox(boxName);
    return box;
  }

}