// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liquid_event_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiquidEventSimple _$LiquidEventSimpleFromJson(Map<String, dynamic> json) =>
    LiquidEventSimple(
      userId: json['userId'] as String,
      date: json['date'] as int,
      drinks: (json['drinks'] as List<dynamic>?)
          ?.map((e) => LiquidInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LiquidEventSimpleToJson(LiquidEventSimple instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'date': instance.date,
      'drinks': instance.drinks?.map((e) => e.toJson()).toList(),
    };

LiquidInEvent _$LiquidInEventFromJson(Map<String, dynamic> json) =>
    LiquidInEvent(
      id: json['id'] as int,
      qty: json['qty'] as int,
    );

Map<String, dynamic> _$LiquidInEventToJson(LiquidInEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
    };
