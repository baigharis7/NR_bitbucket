// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rdas_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRdasResponse _$UserRdasResponseFromJson(Map<String, dynamic> json) =>
    UserRdasResponse(
      n: json['n'] as String,
      rda: json['rda'] as num,
      ul: json['ul'] as num,
    );

Map<String, dynamic> _$UserRdasResponseToJson(UserRdasResponse instance) =>
    <String, dynamic>{
      'n': instance.n,
      'rda': instance.rda,
      'ul': instance.ul,
    };
