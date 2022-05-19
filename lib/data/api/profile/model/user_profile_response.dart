import 'dart:core';

import 'package:json_annotation/json_annotation.dart';

part 'user_profile_response.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfileResponse {
  bool uploadSuccess;
  List<String> micronutrients;

  UserProfileResponse({required this.uploadSuccess, required this.micronutrients});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

}