import 'package:json_annotation/json_annotation.dart';

part 'units_foods_master.g.dart';

@JsonSerializable(explicitToJson: true)
class UnitsFoodsMaster {
  List<UnitFoodMaster> unitsFoodsMaster;

  UnitsFoodsMaster({required this.unitsFoodsMaster});

  factory UnitsFoodsMaster.fromJson(Map<String, dynamic> json) => _$UnitsFoodsMasterFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsFoodsMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UnitFoodMaster {
  int id;
  String units;

  UnitFoodMaster({required this.id, required this.units});
  UnitFoodMaster.empty({this.id = 0, this.units = ''});

  factory UnitFoodMaster.fromJson(Map<String, dynamic> json) => _$UnitFoodMasterFromJson(json);
  Map<String, dynamic> toJson() => _$UnitFoodMasterToJson(this);

}