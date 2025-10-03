import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'supplements_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class SupplementsInfoMaster {
  int v;
  List<SupplementInfoMaster> data;

  SupplementsInfoMaster({required this.v, required this.data});

  factory SupplementsInfoMaster.fromJson(Map<String, dynamic> json) => _$SupplementsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SupplementInfoMaster extends Translatable {
  int id;
  String es;
  String en;
  String unit;

  SupplementInfoMaster({required this.id, required this.es, required this.en, required this.unit});

  factory SupplementInfoMaster.fromJson(Map<String, dynamic> json) => _$SupplementInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SupplementInfoMasterToJson(this);
}