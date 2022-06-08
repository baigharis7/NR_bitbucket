import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_rdas_response.dart';

part 'user_profile_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfileResponse {
  bool uploadSuccess;
  List<String> micronutrients;
  List<UserRdasResponse> userRdas;

  UserProfileResponse({required this.uploadSuccess, required this.micronutrients, required this.userRdas});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

}