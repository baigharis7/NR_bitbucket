import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sleep_event_entity.g.dart';

/// Stores daily sleep data synced from Health Connect / HealthKit.
/// Keyed by eventDate (midnight millis) so each day has exactly one record.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.sleepEventEntity)
class SleepEventEntity extends HiveObject {
  static const boxName = 'sleep_events';

  @HiveField(0) String? userId;

  /// Midnight timestamp (milliseconds since epoch) for the date this record belongs to.
  @HiveField(1) int eventDate;

  /// Unique identifier — same as eventDate for one-per-day semantics.
  @HiveField(2) int eventId;

  /// Total sleep duration in minutes.
  @HiveField(3) int sleepMinutes;

  SleepEventEntity({
    this.userId,
    required this.eventDate,
    required this.eventId,
    required this.sleepMinutes,
  });

  factory SleepEventEntity.fromJson(Map<String, dynamic> json) =>
      _$SleepEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SleepEventEntityToJson(this);
}
