import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';
import 'package:nutrenaissance_flutter/data/local/local_storage_helper.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodevents/food_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_rdas_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_rdas.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

abstract class LocalStorageRepository extends LocalStorageHelper {

  Future<UserProfileEntity?> getProfile();
  Future<List> getAllFoodEvents();
  Future<FoodEventComplete> getLastFoodEvent();
  Future<void> saveProfile(UserProfileEntity profileEntity);
  Future<void> saveFoodEvent(FoodEventEntity foodEventEntity);
  Future<void> saveMasterFile(MasterFilesType masterFileType, dynamic masterFile);
  Future<dynamic> getMasterFile(MasterFilesType masterFileType);
  Future<int> getMasterFileVersion(MasterFilesType masterFileType);
  Future<bool> checkProfileExistence();
  Future<void> saveUserRdas(List<UserRdasResponse> userRdas);
  Future<List<UserRdas>> getUserRdas();
  Future<void> saveSportEvent(SportEventEntity sportEventEntity);
}