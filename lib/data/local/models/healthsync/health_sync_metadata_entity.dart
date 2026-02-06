import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'health_sync_metadata_entity.g.dart';

/// Tracks which health platform activities have been synced to prevent duplicates.
/// Each entry maps a health platform's unique ID to our internal sportEventId.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.healthSyncMetadataEntity)
class HealthSyncMetadataEntity extends HiveObject {
  static const boxName = 'health_sync_metadata';

  /// Unique identifier from HealthKit/Health Connect (uuid)
  @HiveField(0) String healthPlatformId;

  /// Our internal sport event ID
  @HiveField(1) int sportEventId;

  /// Timestamp when this activity was synced (milliseconds since epoch)
  @HiveField(2) int syncedAt;

  /// Source type: 'apple_health' or 'health_connect'
  @HiveField(3) String sourceType;

  HealthSyncMetadataEntity({
    required this.healthPlatformId,
    required this.sportEventId,
    required this.syncedAt,
    required this.sourceType,
  });

  factory HealthSyncMetadataEntity.fromJson(Map<String, dynamic> json) =>
      _$HealthSyncMetadataEntityFromJson(json);
  Map<String, dynamic> toJson() => _$HealthSyncMetadataEntityToJson(this);
}
