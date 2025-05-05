import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'models_appearance_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.modelsAppearanceEntity)
class ModelsAppearanceEntity extends HiveObject {
  static const boxName = 'models_appearance';

  @HiveField(0) int id;
  @HiveField(1) int timeClicked;
  @HiveField(2) int time;

  ModelsAppearanceEntity({required this.id, required this.timeClicked, required this.time});
}