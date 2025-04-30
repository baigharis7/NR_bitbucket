// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models_appearance_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelsAppearanceEntityAdapter
    extends TypeAdapter<ModelsAppearanceEntity> {
  @override
  final int typeId = 66;

  @override
  ModelsAppearanceEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModelsAppearanceEntity(
      id: fields[0] as int,
      timeClicked: fields[1] as int,
      time: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ModelsAppearanceEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timeClicked)
      ..writeByte(2)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelsAppearanceEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelsAppearanceEntity _$ModelsAppearanceEntityFromJson(
        Map<String, dynamic> json) =>
    ModelsAppearanceEntity(
      id: (json['id'] as num).toInt(),
      timeClicked: (json['timeClicked'] as num).toInt(),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$ModelsAppearanceEntityToJson(
        ModelsAppearanceEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timeClicked': instance.timeClicked,
      'time': instance.time,
    };
