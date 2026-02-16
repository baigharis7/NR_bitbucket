// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueEntryAdapter extends TypeAdapter<SyncQueueEntry> {
  @override
  final int typeId = 82;

  @override
  SyncQueueEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueEntry(
      path: fields[0] as String,
      bodyJson: fields[1] as String,
      createdAt: fields[2] as int,
      retryCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.bodyJson)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
