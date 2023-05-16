// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explaining_card_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExplainingCardEntityAdapter extends TypeAdapter<ExplainingCardEntity> {
  @override
  final int typeId = 46;

  @override
  ExplainingCardEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExplainingCardEntity(
      id: fields[0] as int,
      timesClicked: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExplainingCardEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timesClicked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplainingCardEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExplainingCardEntity _$ExplainingCardEntityFromJson(
        Map<String, dynamic> json) =>
    ExplainingCardEntity(
      id: json['id'] as int,
      timesClicked: json['timesClicked'] as int,
    );

Map<String, dynamic> _$ExplainingCardEntityToJson(
        ExplainingCardEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timesClicked': instance.timesClicked,
    };
