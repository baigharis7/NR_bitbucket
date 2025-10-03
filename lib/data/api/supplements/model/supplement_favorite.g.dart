// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplement_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementFavorite _$SupplementFavoriteFromJson(Map<String, dynamic> json) =>
    SupplementFavorite(
      userId: json['userId'] as String,
      eventId: json['eventId'] as int,
      eventDate: json['eventDate'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
          SupplementFavoriteNutrient.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String, // 👈 if you keep it int, change to `as int`
    );

Map<String, dynamic> _$SupplementFavoriteToJson(SupplementFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'data': instance.data.map((e) => e.toJson()).toList(),
      'name': instance.name,
    };

SupplementFavoriteNutrient _$SupplementFavoriteNutrientFromJson(Map<String, dynamic> json) =>
    SupplementFavoriteNutrient(
      id: json['id'] as int,
      amount: json['amount'] as int,
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$SupplementFavoriteNutrientToJson(SupplementFavoriteNutrient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'unit': instance.unit,
    };