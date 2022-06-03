import 'package:json_annotation/json_annotation.dart';

part 'cooking_methods_master.g.dart';

@JsonSerializable(explicitToJson: true)
class CookingMethodsMaster {
  @JsonKey(name: 'data')
  List<CookingMethod> cookingMethods;

  CookingMethodsMaster({required this.cookingMethods});

  factory CookingMethodsMaster.fromJson(Map<String, dynamic> json) => _$CookingMethodsMasterFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookingMethod {
  @JsonKey(name: 'group')
  String group;
  @JsonKey(name: 'methods')
  List<int> methods;

  CookingMethod({required this.group, required this.methods});
  CookingMethod.empty({this.group = '0', this.methods = const []});

  factory CookingMethod.fromJson(Map<String, dynamic> json) => _$CookingMethodFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodToJson(this);
}