// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rdas_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRdasEntityAdapter extends TypeAdapter<UserRdasEntity> {
  @override
  final int typeId = 25;

  @override
  UserRdasEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserRdasEntity(
      n: fields[0] as String,
      rda: fields[1] as double,
      ul: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserRdasEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.n)
      ..writeByte(1)
      ..write(obj.rda)
      ..writeByte(2)
      ..write(obj.ul);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRdasEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRdasEntity _$UserRdasEntityFromJson(Map<String, dynamic> json) =>
    UserRdasEntity(
      n: json['n'] as String,
      rda: (json['rda'] as num).toDouble(),
      ul: (json['ul'] as num).toDouble(),
    );

Map<String, dynamic> _$UserRdasEntityToJson(UserRdasEntity instance) =>
    <String, dynamic>{
      'n': instance.n,
      'rda': instance.rda,
      'ul': instance.ul,
    };
