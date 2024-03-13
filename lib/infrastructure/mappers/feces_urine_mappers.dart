import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/data/local/models/fecesurine/upload_feces_event_entity.dart';

UploadFecesEventEntity mapToUploadFecesEventEntity(UploadFeces uploadFeces) =>
    UploadFecesEventEntity(
      userId: uploadFeces.userId,
      eventId: uploadFeces.eventId,
      fecesId: uploadFeces.fecesId,
    );

UploadFeces mapToUploadFeces(UploadFecesEventEntity uploadFecesEventEntity) =>
    UploadFeces(
      userId: uploadFecesEventEntity.userId,
      eventId: uploadFecesEventEntity.eventId,
      fecesId: uploadFecesEventEntity.fecesId,
    );
