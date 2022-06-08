// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileResponse _$UserProfileResponseFromJson(Map<String, dynamic> json) =>
    UserProfileResponse(
      uploadSuccess: json['uploadSuccess'] as bool,
      micronutrients: (json['micronutrients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      userRdas: (json['userRdas'] as List<dynamic>)
          .map((e) => UserRdasResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserProfileResponseToJson(
        UserProfileResponse instance) =>
    <String, dynamic>{
      'uploadSuccess': instance.uploadSuccess,
      'micronutrients': instance.micronutrients,
      'userRdas': instance.userRdas.map((e) => e.toJson()).toList(),
    };
