import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'objectives_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class ObjectivesInfoMaster {
  List<ObjectiveInfoMaster> objectives;
  List<ObjectiveInfoMaster> metabolicObjectives;
  List<ObjectiveInfoMaster> bodyCompositionObjectives;

  ObjectivesInfoMaster({required this.objectives, required this.metabolicObjectives, required this.bodyCompositionObjectives});

  factory ObjectivesInfoMaster.fromJson(Map<String, dynamic> json) => _$ObjectivesInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectivesInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ObjectiveInfoMaster extends Translatable {
  int id;
  String en;
  String es;

  ObjectiveInfoMaster({required this.id, required this.en, required this.es});

  factory ObjectiveInfoMaster.fromJson(Map<String, dynamic> json) => _$ObjectiveInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectiveInfoMasterToJson(this);
}