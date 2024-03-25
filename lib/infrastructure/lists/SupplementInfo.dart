import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';

import '../../domain/models/masterfiles/translatable.dart';

@JsonSerializable(explicitToJson: true)
class SupplementInfo extends Translatable {
  String? name_en;
  String? name_es;
  UploadSupplementEvent? uploadSupplementEvent;
  num? rda;

  SupplementInfo(this.name_en, this.name_es, this.uploadSupplementEvent, this.rda);

  SupplementInfo.empty() {
    name_en = null;
    name_es = null;
    uploadSupplementEvent = UploadSupplementEvent(userId: '-1', eventId: -1, value: 0);
    rda  = null;
  }

  factory SupplementInfo.fromJson(Map<String, dynamic> json) {
    return SupplementInfo(
      json["name_en"],
      json["name_es"],
      UploadSupplementEvent.fromJson(json["uploadSupplementEvent"]),
      json["rda"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name_en": this.name_en,
      "name_es": this.name_es,
      "uploadSupplementEvent": this.uploadSupplementEvent,
      "rda": this.rda,
    };
  }
}