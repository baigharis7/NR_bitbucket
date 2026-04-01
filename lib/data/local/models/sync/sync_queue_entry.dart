import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'sync_queue_entry.g.dart';

@HiveType(typeId: HiveTypeIds.syncQueueEntry)
class SyncQueueEntry extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  String bodyJson;

  @HiveField(2)
  int createdAt;

  @HiveField(3)
  int retryCount;

  @HiveField(4)
  String method;

  /// Epoch millis — entry won't be retried before this time.
  @HiveField(5)
  int nextRetryAt;

  SyncQueueEntry({
    required this.path,
    required this.bodyJson,
    required this.createdAt,
    this.retryCount = 0,
    this.method = 'POST',
    this.nextRetryAt = 0,
  });
}
