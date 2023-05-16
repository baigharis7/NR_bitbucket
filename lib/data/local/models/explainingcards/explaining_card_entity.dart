import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'explaining_card_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.explainingCardEntity)
class ExplainingCardEntity extends HiveObject {
  static const boxName = 'explaining_cards';

  @HiveField(0) int id;
  @HiveField(1) int timesClicked;

  ExplainingCardEntity({required this.id, required this.timesClicked});
}