import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'steps_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.addStepsEntity)
class StepsEntity extends HiveObject {
  static const boxName = 'step_events';

  @HiveField(0) int? eventId;
  @HiveField(1) int? initialSteps;
  @HiveField(3) int? actualSteps;

  StepsEntity({required this.eventId, required this.initialSteps, required this.actualSteps});

  factory StepsEntity.fromJson(Map<String, dynamic> json) => _$StepsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$StepsEntityToJson(this);
}
