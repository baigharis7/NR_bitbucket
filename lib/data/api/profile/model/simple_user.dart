import 'package:json_annotation/json_annotation.dart';

part 'simple_user.g.dart';

@JsonSerializable()
class SimpleUser {
  String email;
  String userName;
  String userId;

  SimpleUser({required this.email, required this.userName, required this.userId});

  factory SimpleUser.fromJson(Map<String, dynamic> json) => _$SimpleUserFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleUserToJson(this);
}