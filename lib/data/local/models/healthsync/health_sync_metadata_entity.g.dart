// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_sync_metadata_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthSyncMetadataEntityAdapter
    extends TypeAdapter<HealthSyncMetadataEntity> {
  @override
  final int typeId = 83;

  @override
  HealthSyncMetadataEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthSyncMetadataEntity(
      healthPlatformId: fields[0] as String,
      sportEventId: fields[1] as int,
      syncedAt: fields[2] as int,
      sourceType: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HealthSyncMetadataEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.healthPlatformId)
      ..writeByte(1)
      ..write(obj.sportEventId)
      ..writeByte(2)
      ..write(obj.syncedAt)
      ..writeByte(3)
      ..write(obj.sourceType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSyncMetadataEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthSyncMetadataEntity _$HealthSyncMetadataEntityFromJson(
        Map<String, dynamic> json) =>
    HealthSyncMetadataEntity(
      healthPlatformId: json['healthPlatformId'] as String,
      sportEventId: (json['sportEventId'] as num).toInt(),
      syncedAt: (json['syncedAt'] as num).toInt(),
      sourceType: json['sourceType'] as String,
    );

Map<String, dynamic> _$HealthSyncMetadataEntityToJson(
        HealthSyncMetadataEntity instance) =>
    <String, dynamic>{
      'healthPlatformId': instance.healthPlatformId,
      'sportEventId': instance.sportEventId,
      'syncedAt': instance.syncedAt,
      'sourceType': instance.sourceType,
    };
