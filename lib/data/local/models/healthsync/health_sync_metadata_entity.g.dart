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
      normalizedType: fields[4] as String?,
      startTimeMs: fields[5] as int?,
      endTimeMs: fields[6] as int?,
      sourceCategory: fields[7] as String?,
      deletedAtMs: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthSyncMetadataEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.healthPlatformId)
      ..writeByte(1)
      ..write(obj.sportEventId)
      ..writeByte(2)
      ..write(obj.syncedAt)
      ..writeByte(3)
      ..write(obj.sourceType)
      ..writeByte(4)
      ..write(obj.normalizedType)
      ..writeByte(5)
      ..write(obj.startTimeMs)
      ..writeByte(6)
      ..write(obj.endTimeMs)
      ..writeByte(7)
      ..write(obj.sourceCategory)
      ..writeByte(8)
      ..write(obj.deletedAtMs);
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
      normalizedType: json['normalizedType'] as String?,
      startTimeMs: (json['startTimeMs'] as num?)?.toInt(),
      endTimeMs: (json['endTimeMs'] as num?)?.toInt(),
      sourceCategory: json['sourceCategory'] as String?,
      deletedAtMs: (json['deletedAtMs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HealthSyncMetadataEntityToJson(
        HealthSyncMetadataEntity instance) =>
    <String, dynamic>{
      'healthPlatformId': instance.healthPlatformId,
      'sportEventId': instance.sportEventId,
      'syncedAt': instance.syncedAt,
      'sourceType': instance.sourceType,
      'normalizedType': instance.normalizedType,
      'startTimeMs': instance.startTimeMs,
      'endTimeMs': instance.endTimeMs,
      'sourceCategory': instance.sourceCategory,
      'deletedAtMs': instance.deletedAtMs,
    };
