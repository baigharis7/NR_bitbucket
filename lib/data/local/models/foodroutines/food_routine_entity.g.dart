// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_routine_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodRoutineEntityAdapter extends TypeAdapter<FoodRoutineEntity> {
  @override
  final int typeId = 74;

  @override
  FoodRoutineEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodRoutineEntity(
      userId: fields[0] as String,
      eventDate: fields[1] as int,
      eventId: fields[2] as int?,
      mealType: fields[3] as int?,
      foodName: fields[4] as String?,
      comment: fields[5] as String?,
      ingredients: (fields[6] as List?)?.cast<FoodRoutineInEntity>(),
      drinks: (fields[7] as List?)?.cast<FoodRoutineInEntity>(),
      dish: fields[8] as bool?,
      isRoutine: fields[9] as bool?,
      daysOfWeek: (fields[10] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodRoutineEntity obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.foodName)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.ingredients)
      ..writeByte(7)
      ..write(obj.drinks)
      ..writeByte(8)
      ..write(obj.dish)
      ..writeByte(9)
      ..write(obj.isRoutine)
      ..writeByte(10)
      ..write(obj.daysOfWeek)
      ..writeByte(11)
      ..write(obj.timeZone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodRoutineEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodRoutineInEntityAdapter extends TypeAdapter<FoodRoutineInEntity> {
  @override
  final int typeId = 75;

  @override
  FoodRoutineInEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodRoutineInEntity(
      id: fields[0] as int,
      qty: fields[1] as int,
      unit: fields[2] as int,
      conversionFactor: fields[3] as int?,
      cookingMethod: fields[4] as int,
      usedOil: fields[5] as int?,
      unitsEquivalences: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodRoutineInEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.qty)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.conversionFactor)
      ..writeByte(4)
      ..write(obj.cookingMethod)
      ..writeByte(5)
      ..write(obj.usedOil)
      ..writeByte(6)
      ..write(obj.unitsEquivalences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodRoutineInEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodRoutineEntity _$FoodRoutineEntityFromJson(Map<String, dynamic> json) =>
    FoodRoutineEntity(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      eventId: (json['eventId'] as num?)?.toInt(),
      mealType: (json['mealType'] as num?)?.toInt(),
      foodName: json['foodName'] as String?,
      comment: json['comment'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => FoodRoutineInEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>?)
          ?.map((e) => FoodRoutineInEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      dish: json['dish'] as bool?,
      isRoutine: json['isRoutine'] as bool?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String?,
      schedule: json['schedule'] as String?,
    );

Map<String, dynamic> _$FoodRoutineEntityToJson(FoodRoutineEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'mealType': instance.mealType,
      'foodName': instance.foodName,
      'comment': instance.comment,
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks?.map((e) => e.toJson()).toList(),
      'dish': instance.dish,
      'isRoutine': instance.isRoutine,
      'daysOfWeek': instance.daysOfWeek,
      'timeZone': instance.timeZone,
      'schedule': instance.schedule,
    };

FoodRoutineInEntity _$FoodRoutineInEntityFromJson(Map<String, dynamic> json) =>
    FoodRoutineInEntity(
      id: (json['id'] as num).toInt(),
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      conversionFactor: (json['conversionFactor'] as num?)?.toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      usedOil: (json['usedOil'] as num?)?.toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$FoodRoutineInEntityToJson(
        FoodRoutineInEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'conversionFactor': instance.conversionFactor,
      'cookingMethod': instance.cookingMethod,
      'usedOil': instance.usedOil,
      'unitsEquivalences': instance.unitsEquivalences,
    };
