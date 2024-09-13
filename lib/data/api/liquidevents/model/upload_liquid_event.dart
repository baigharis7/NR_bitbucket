import 'package:json_annotation/json_annotation.dart';

part 'upload_liquid_event.g.dart';

@JsonSerializable(explicitToJson: true)
class UploadLiquidEvent {
  String? userId;
  int? eventDate;
  List<LiquidInfo>? liquidInfo;
  bool uploadSuccess;
  int? eventKcals;

  UploadLiquidEvent(
      this.userId,
      this.eventDate,
      this.liquidInfo,
      this.eventKcals,
      {this.uploadSuccess = false,}
  );

  factory UploadLiquidEvent.fromJson(Map<String, dynamic> json) => _$UploadLiquidEventFromJson(json);
  Map<String, dynamic> toJson() => _$UploadLiquidEventToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LiquidInfo {
  EventInfo? eventInfo;
  String? group;
  int? id;
  // TODO: quitar "name"
  String? name_en;
  String? name_es;
  int? recommendable;
  Params? params;
  String? freeSugar;

  LiquidInfo(
      this.eventInfo,
      this.group,
      this.id,
      this.name_en,
      this.name_es,
      this.recommendable,
      this.params,
      this.freeSugar,
      );

  factory LiquidInfo.fromJson(Map<String, dynamic> json) => _$LiquidInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LiquidInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EventInfo {
  int? cookingMethod;
  double? qty;
  int? unit;
  double? waste;

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
class Params {
  double? alanine;
  double? arginine;
  double? arsenic;
  double? ash;
  double? asparticAcid;
  double? benzoicAcid;
  double? betacaroteneVitA;
  double? c16_0;
  double? c18_0;
  double? c18_1N_9;
  double? c18_2N_6;
  double? c18_3N_3;
  double? cadmium;
  double? calcium;
  double? carbsAvailable;
  double? carbsByDiff;
  double? carbsDeclared;
  double? celulose;
  double? chromium;
  double? copper;
  double? cystine;
  double? dryMatter;
  double? energyKcal;
  double? energyKJ;
  double? fatTotal;
  double? fattyAcidConversionFactor;
  double? fattyAcidsTotal;
  double? fiber;
  double? fructose;
  double? glucose;
  double? glutamicAcid;
  double? glycine;
  double? hexose;
  double? histamine;
  double? histidine;
  double? hydroxyproline;
  double? iodine;
  double? iron;
  double? isoleucine;
  double? lead;
  double? leucine;
  double? lignin;
  double? lysine;
  double? magnesium;
  double? manganese;
  double? mercury;
  double? methionine;
  double? monosaccharidesTotal;
  double? nickel;
  double? nitro2protein;
  double? nitrogen;
  double? pentose;
  double? phenylalanine;
  double? phosphorus;
  double? potassium;
  double? proline;
  double? proteinLabel;
  double? proteinSci;
  double? selenium;
  double? serin;
  double? sodium;
  double? starch;
  double? sugarsTotal;
  double? sumMonoUnsat;
  double? sumN3FattyAcids;
  double? sumN6FattyAcids;
  double? sumPolyUnsat;
  double? sumSat;
  double? sulfur;
  double? threonine;
  double? tryptophan;
  double? tyrosine;
  double? uronicAcid;
  double? valin;
  double? vitA;
  double? vitB1;
  double? vitB2;
  double? vitB3;
  double? vitB3Eq;
  double? vitB5;
  double? vitB6;
  double? vitB7;
  double? vitB9;
  double? vitB9Free;
  double? vitB12;
  double? vitC;
  double? vitCL;
  double? vitCLDehydro;
  double? vitD;
  double? vitD2;
  double? vitD3;
  double? vitD_25hydroxi;
  double? vitD3_25hydroxi;
  double? vitE;
  double? vitE_alphaTP;
  double? other;
  double? saturated;
  double? monounsaturated;
  double? polyunsaturated;
  double? totalTrans;
  double? total;
  double? n3;
  double? n6;
  double? cholesterol;
  double? water;
  double? zinc;
  double? chloride;
  double? molybdenum;
  double? cobalt;
  double? fluoron;
  double? silicon;
  double? rubidium;
  double? aluminum;
  double? boron;
  double? bromine;
  double? arsenInorganic;
  double? omega3;

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
      this.omega3,
      );

  factory Params.fromJson(Map<String, dynamic> json) => _$ParamsFromJson(json);
  Map<String, dynamic> toJson() => _$ParamsToJson(this);
}