import 'package:json_annotation/json_annotation.dart';

part 'nutrients_objective.g.dart';

@JsonSerializable(explicitToJson: true)
class NutrientsObjective {
  List<NutrientInfo>? nutrients;
  
  NutrientsObjective({required this.nutrients});

  factory NutrientsObjective.fromJson(Map<String, dynamic> json) => _$NutrientsObjectiveFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsObjectiveToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NutrientInfo {
  // TODO: darle una vuelta a si todos pueden ser nullables.
  int? id;
  String? name;
  int? sol;
  String? unit;
  double? convFactor;
  double? male1;
  double? male2;
  double? male3;
  double? male4;
  double? female1;
  double? female2;
  double? female3;
  double? female4;
  double? pregnancy1;
  double? pregnancy2;
  double? lactancy1;
  double? lactancy2;
  double? ulMale1;
  double? ulMale2;
  double? ulMale3;
  double? ulFemale1;
  double? ulFemale2;
  double? ulFemale3;
  double? ulPregnancy;
  List<int>? objectives;

  NutrientInfo({
    required this.id, 
    required this.name, 
    required this.sol, 
    required this.unit,
    this.convFactor,
    this.male1,
    this.male2,
    this.male3,
    this.male4,
    this.female1,
    this.female2,
    this.female3,
    this.female4,
    this.pregnancy1,
    this.pregnancy2,
    this.lactancy1,
    this.lactancy2,
    this.ulMale1,
    this.ulMale2,
    this.ulMale3,
    this.ulFemale1,
    this.ulFemale2,
    this.ulFemale3,
    this.ulPregnancy,
    this.objectives,
  });

  factory NutrientInfo.fromJson(Map<String, dynamic> json) => _$NutrientInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoToJson(this);
}