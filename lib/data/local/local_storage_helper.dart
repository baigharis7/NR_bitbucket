import 'package:hive/hive.dart';

abstract class LocalStorageHelper {

  Future<Box> openBox(Box? box, String boxName) async {
    if (box == null || !box.isOpen) box = await Hive.openBox(boxName);
    return box;
  }

}