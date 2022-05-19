import '../../models/masterfiles/food_names_master.dart';

abstract class MasterFilesRepository {
  FoodAndDrinksNamesMaster? getFoodAndDrinksNames();
}