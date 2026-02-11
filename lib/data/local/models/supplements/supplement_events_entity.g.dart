// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplement_events_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplementEventsEntityAdapter
    extends TypeAdapter<SupplementEventsEntity> {
  @override
  final int typeId = 78;

  @override
  SupplementEventsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplementEventsEntity(
      userId: fields[0] as String,
      eventId: fields[1] as int,
      eventDate: fields[2] as int,
      info: (fields[3] as List).cast<SupplementEventsInfoEntity>(),
      name: fields[4] as String?,
      scheduleTime: fields[5] as String?,
      daysOfWeek: (fields[6] as List?)?.cast<int>(),
      timeZone: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplementEventsEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.eventDate)
      ..writeByte(3)
      ..write(obj.info)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.scheduleTime)
      ..writeByte(6)
      ..write(obj.daysOfWeek)
      ..writeByte(7)
      ..write(obj.timeZone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementEventsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupplementEventsInfoEntityAdapter
    extends TypeAdapter<SupplementEventsInfoEntity> {
  @override
  final int typeId = 79;

  @override
  SupplementEventsInfoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplementEventsInfoEntity(
      id: fields[0] as int,
      amount: fields[1] as String,
      unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupplementEventsInfoEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementEventsInfoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementEventsEntity _$SupplementEventsEntityFromJson(
        Map<String, dynamic> json) =>
    SupplementEventsEntity(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventDate: (json['eventDate'] as num).toInt(),
      info: (json['info'] as List<dynamic>)
          .map((e) =>
              SupplementEventsInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
      scheduleTime: json['scheduleTime'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SupplementEventsEntityToJson(
        SupplementEventsEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'info': instance.info.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'scheduleTime': instance.scheduleTime,
      'daysOfWeek': instance.daysOfWeek,
      'timeZone': instance.timeZone,
    };

SupplementEventsInfoEntity _$SupplementEventsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    SupplementEventsInfoEntity(
      id: (json['id'] as num).toInt(),
      amount: json['amount'] as String,
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$SupplementEventsInfoEntityToJson(
        SupplementEventsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'unit': instance.unit,
    };
