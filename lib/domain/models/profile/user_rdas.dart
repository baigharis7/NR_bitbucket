import 'package:json_annotation/json_annotation.dart';

part 'user_rdas.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRdas {
  String name;
  num rda;
  num ul;

  UserRdas({required this.name, required this.rda, required this.ul});

  factory UserRdas.fromJson(Map<String, dynamic> json) => _$UserRdasFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdasToJson(this);
}