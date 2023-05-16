import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'food_event_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodEventEntity)
class FoodEventEntity extends HiveObject {
  static const boxName = 'food_events';

  @HiveField(0) String? userId;
  @HiveField(1) int? eventDate;
  @HiveField(2) List<FoodInfo>? foodInfo;
  @HiveField(3) int? eventKcals;

  FoodEventEntity(
      this.userId,
      this.eventDate,
      this.foodInfo,
      this.eventKcals,
  );

  factory FoodEventEntity.fromJson(Map<String, dynamic> json) => _$FoodEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FoodEventEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.foodInfo)
class FoodInfo {
  // @HiveField(0) int? exchangePortion;
  // String? exchangePortionDaily;
  @HiveField(0) String? group;
  @HiveField(1) int? id;
  // TODO: quitar "name"
  @HiveField(2) String? name_en;
  @HiveField(3) String? name_es;
  // TODO: este tiene que ser un int.
  // @HiveField(5) String? portionSenc;
  @HiveField(4) int? recommendable;
  @HiveField(5) EventInfo? eventInfo;
  @HiveField(6) Params? params;

  factory FoodInfo.fromJson(Map<String, dynamic> json) => _$FoodInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FoodInfoToJson(this);
  FoodInfo(
      // this.exchangePortion,
      // this.exchangePortionDaily,
      this.group,
      this.id,
      this.name_en,
      this.name_es,
      // this.portionSenc,
      this.recommendable,
      this.eventInfo,
      this.params,
      );
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.eventInfo)
class EventInfo { // TODO nombre
  @HiveField(0) int? cookingMethod;
  @HiveField(1) double? qty;
  @HiveField(2) int? unit;
  @HiveField(3) double? waste;

  EventInfo(
      this.cookingMethod,
      this.qty,
      this.unit,
      this.waste,
  );

  factory EventInfo.fromJson(Map<String, dynamic> json) => _$EventInfoFromJson(json);
  Map<String, dynamic> toJson() => _$EventInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.params)
class Params {
  @HiveField(0) double? alanine;
  @HiveField(1) double? arginine;
  @HiveField(2) double? arsenic;
  @HiveField(3) double? ash;
  @HiveField(4) double? asparticAcid;
  @HiveField(5) double? benzoicAcid;
  @HiveField(6) double? betacaroteneVitA;
  @HiveField(7) double? c16_0;
  @HiveField(8) double? c18_0;
  @HiveField(9) double? c18_1N_9;
  @HiveField(10) double? c18_2N_6;
  @HiveField(11) double? c18_3N_3;
  @HiveField(12) double? cadmium;
  @HiveField(13) double? calcium;
  @HiveField(14) double? carbsAvailable;
  @HiveField(15) double? carbsByDiff;
  @HiveField(16) double? carbsDeclared;
  @HiveField(17) double? celulose;
  @HiveField(18) double? chromium;
  @HiveField(19) double? copper;
  @HiveField(20) double? cystine;
  @HiveField(21) double? dryMatter;
  @HiveField(22) double? energyKcal;
  @HiveField(23) double? energyKJ;
  @HiveField(24) double? fatTotal;
  @HiveField(25) double? fattyAcidConversionFactor;
  @HiveField(26) double? fattyAcidsTotal;
  @HiveField(27) double? fiber;
  @HiveField(28) double? fructose;
  @HiveField(29) double? glucose;
  @HiveField(30) double? glutamicAcid;
  @HiveField(31) double? glycine;
  @HiveField(32) double? hexose;
  @HiveField(33) double? histamine;
  @HiveField(34) double? histidine;
  @HiveField(35) double? hydroxyproline;
  @HiveField(36) double? iodine;
  @HiveField(37) double? iron;
  @HiveField(38) double? isoleucine;
  @HiveField(39) double? lead;
  @HiveField(40) double? leucine;
  @HiveField(41) double? lignin;
  @HiveField(42) double? lysine;
  @HiveField(43) double? magnesium;
  @HiveField(44) double? manganese;
  @HiveField(45) double? mercury;
  @HiveField(46) double? methionine;
  @HiveField(47) double? monosaccharidesTotal;
  @HiveField(48) double? nickel;
  @HiveField(49) double? nitro2protein;
  @HiveField(50) double? nitrogen;
  @HiveField(51) double? pentose;
  @HiveField(52) double? phenylalanine;
  @HiveField(53) double? phosphorus;
  @HiveField(54) double? potassium;
  @HiveField(55) double? proline;
  @HiveField(56) double? proteinLabel;
  @HiveField(57) double? proteinSci;
  @HiveField(58) double? selenium;
  @HiveField(59) double? serin;
  @HiveField(60) double? sodium;
  @HiveField(61) double? starch;
  @HiveField(62) double? sugarsTotal;
  @HiveField(63) double? sumMonoUnsat;
  @HiveField(64) double? sumN3FattyAcids;
  @HiveField(65) double? sumN6FattyAcids;
  @HiveField(66) double? sumPolyUnsat;
  @HiveField(67) double? sumSat;
  @HiveField(68) double? sulfur;
  @HiveField(69) double? threonine;
  @HiveField(70) double? tryptophan;
  @HiveField(71) double? tyrosine;
  @HiveField(72) double? uronicAcid;
  @HiveField(73) double? valin;
  @HiveField(74) double? vitA;
  @HiveField(75) double? vitB1;
  @HiveField(76) double? vitB2;
  @HiveField(77) double? vitB3;
  @HiveField(78) double? vitB3Eq;
  @HiveField(79) double? vitB5;
  @HiveField(80) double? vitB6;
  @HiveField(81) double? vitB7;
  @HiveField(82) double? vitB9;
  @HiveField(83) double? vitB9Free;
  @HiveField(84) double? vitB12;
  @HiveField(85) double? vitC;
  @HiveField(86) double? vitCL;
  @HiveField(87) double? vitCLDehydro;
  @HiveField(88) double? vitD;
  @HiveField(89) double? vitD2;
  @HiveField(90) double? vitD3;
  @HiveField(91) double? vitD_25hydroxi;
  @HiveField(92) double? vitD3_25hydroxi;
  @HiveField(93) double? vitE;
  @HiveField(94) double? vitE_alphaTP;
  @HiveField(95) double? other;
  @HiveField(96) double? saturated;
  @HiveField(97) double? monounsaturated;
  @HiveField(98) double? polyunsaturated;
  @HiveField(99) double? totalTrans;
  @HiveField(100) double? total;
  @HiveField(101) double? n3;
  @HiveField(102) double? n6;
  @HiveField(103) double? cholesterol;
  @HiveField(104) double? water;
  @HiveField(105) double? zinc;
  @HiveField(106) double? chloride;
  @HiveField(107) double? molybdenum;
  @HiveField(108) double? cobalt;
  @HiveField(109) double? fluoron;
  @HiveField(110) double? silicon;
  @HiveField(111) double? rubidium;
  @HiveField(112) double? aluminum;
  @HiveField(113) double? boron;
  @HiveField(114) double? bromine;
  @HiveField(115) double? arsenInorganic;

  Params(
        this.alanine,
        this.arginine,
        this.arsenic,
        this.ash,
        this.asparticAcid,
        this.benzoicAcid,
        this.betacaroteneVitA,
        this.c16_0,
        this.c18_0,
        this.c18_1N_9,
        this.c18_2N_6,
        this.c18_3N_3,
        this.cadmium,
        this.calcium,
        this.carbsAvailable,
        this.carbsByDiff,
        this.carbsDeclared,
        this.celulose,
        this.chromium,
        this.copper,
        this.cystine,
        this.dryMatter,
        this.energyKcal,
        this.energyKJ,
        this.fatTotal,
        this.fattyAcidConversionFactor,
        this.fattyAcidsTotal,
        this.fiber,
        this.fructose,
        this.glucose,
        this.glutamicAcid,
        this.glycine,
        this.hexose,
        this.histamine,
        this.histidine,
        this.hydroxyproline,
        this.iodine,
        this.iron,
        this.isoleucine,
        this.lead,
        this.leucine,
        this.lignin,
        this.lysine,
        this.magnesium,
        this.manganese,
        this.mercury,
        this.methionine,
        this.monosaccharidesTotal,
        this.nickel,
        this.nitro2protein,
        this.nitrogen,
        this.pentose,
        this.phenylalanine,
        this.phosphorus,
        this.potassium,
        this.proline,
        this.proteinLabel,
        this.proteinSci,
        this.selenium,
        this.serin,
        this.sodium,
        this.starch,
        this.sugarsTotal,
        this.sumMonoUnsat,
        this.sumN3FattyAcids,
        this.sumN6FattyAcids,
        this.sumPolyUnsat,
        this.sumSat,
        this.threonine,
        this.tryptophan,
        this.tyrosine,
        this.uronicAcid,
        this.valin,
        this.vitA,
        this.vitB1,
        this.vitB2,
        this.vitB3,
        this.vitB3Eq,
        this.vitB5,
        this.vitB6,
        this.vitB7,
        this.vitB9,
        this.vitB9Free,
        this.vitB12,
        this.vitC,
        this.vitCL,
        this.vitCLDehydro,
        this.vitD,
        this.vitD2,
        this.vitD3,
        this.vitD_25hydroxi,
        this.vitD3_25hydroxi,
        this.vitE,
        this.vitE_alphaTP,
        this.water,
        this.zinc,
        this.other,
        this.saturated,
        this.monounsaturated,
        this.polyunsaturated,
        this.totalTrans,
        this.total,
        this.n3,
        this.n6,
        this.cholesterol,
        this.chloride,
        this.molybdenum,
        this.cobalt,
        this.fluoron,
        this.silicon,
        this.rubidium,
        this.aluminum,
        this.boron,
        this.bromine,
        this.arsenInorganic,
      );

  factory Params.fromJson(Map<String, dynamic> json) => _$ParamsFromJson(json);
  Map<String, dynamic> toJson() => _$ParamsToJson(this);
}