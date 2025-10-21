import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
part 'user_profile_response.g.dart';
@JsonSerializable(explicitToJson: true)
class UserProfileResponse {
  bool uploadSuccess;
  List<String> micronutrients;
  List<String> userAll;
  List<String> temporaryMicronutrients;
  List<String> temporaryAll;
  List<UserRda> userRdas;
  int kcal;
  UserProfileResponse({required this.uploadSuccess, required this.micronutrients, required this.userAll, required this.temporaryMicronutrients, required this.temporaryAll, required this.userRdas, required this.kcal});
  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}