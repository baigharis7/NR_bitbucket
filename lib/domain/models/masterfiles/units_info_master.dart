import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'units_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class UnitsInfoMaster {
  List<UnitInfoMaster> unitsInfoMaster;

  UnitsInfoMaster({required this.unitsInfoMaster});

  factory UnitsInfoMaster.fromJson(Map<String, dynamic> json) => _$UnitsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UnitInfoMaster extends Translatable {
  int id;
  String en;
  String es;

  UnitInfoMaster({required this.id, required this.en, required this.es});
  UnitInfoMaster.empty({this.id = 0, this.en = '', this.es = ''});

  factory UnitInfoMaster.fromJson(Map<String, dynamic> json) => _$UnitInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$UnitInfoMasterToJson(this);

}