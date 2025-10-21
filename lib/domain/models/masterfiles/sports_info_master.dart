import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/translatable.dart';

part 'sports_info_master.g.dart';

@JsonSerializable(explicitToJson: true)
class SportsInfoMaster {
  List<SportInfoMaster> sportsInfoMaster;

  SportsInfoMaster({required this.sportsInfoMaster});

  factory SportsInfoMaster.fromJson(Map<String, dynamic> json) => _$SportsInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SportsInfoMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SportInfoMaster extends Translatable {
  int id;
  String en;
  String es;
  int mets;

  SportInfoMaster({required this.id, required this.en, required this.es, required this.mets});
  SportInfoMaster.empty({this.id = 0, this.en = '', this.es = '', this.mets = 0});

  factory SportInfoMaster.fromJson(Map<String, dynamic> json) => _$SportInfoMasterFromJson(json);
  Map<String, dynamic> toJson() => _$SportInfoMasterToJson(this);

}

