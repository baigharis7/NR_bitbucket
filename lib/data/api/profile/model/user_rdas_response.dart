import 'package:json_annotation/json_annotation.dart';

part 'user_rdas_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRdasResponse {
  String n;
  num rda;
  num ul;

  UserRdasResponse({required this.n, required this.rda, required this.ul});

  factory UserRdasResponse.fromJson(Map<String, dynamic> json) => _$UserRdasResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdasResponseToJson(this);
}