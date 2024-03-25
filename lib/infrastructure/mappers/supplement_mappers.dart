import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/data/local/models/supplements/upload_supplement_event_entity.dart';

UploadSupplementEventEntity mapToSupplementEventEntity(
        UploadSupplementEvent uploadSupplementEvent) =>
    UploadSupplementEventEntity(
      userId: uploadSupplementEvent.userId,
      eventId: uploadSupplementEvent.eventId,
      value: uploadSupplementEvent.value,
    );

UploadSupplementEvent mapToSupplementEvent(
    UploadSupplementEventEntity? uploadSupplementEventEntity) =>
    UploadSupplementEvent(
      userId: uploadSupplementEventEntity?.userId,
      eventId: uploadSupplementEventEntity?.eventId,
      value: uploadSupplementEventEntity?.value,
    );
