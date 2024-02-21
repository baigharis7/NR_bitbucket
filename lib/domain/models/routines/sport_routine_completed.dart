class SportRoutineCompleted {
  String? userId;
  num? eventId;
  String? comment;
  String? sportName;
  String? routineTime;
  List<Info>? info;

  SportRoutineCompleted({
    this.userId,
    this.eventId,
    this.comment,
    this.sportName,
    this.routineTime,
    this.info,
  });

  SportRoutineCompleted.fromJson(dynamic json) {
    userId = json['userId'];
    eventId = json['eventId'];
    comment = json['comment'];
    sportName = json['sportName'];
    routineTime = json['routineTime'];
    if (json['info'] != null) {
      info = [];
      json['info'].forEach((v) {
        info?.add(Info.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    map['eventId'] = eventId;
    map['comment'] = comment;
    map['sportName'] = sportName;
    map['routineTime'] = routineTime;
    if (info != null) {
      map['info'] = info?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Info {
  num? id;
  String? nameEn;
  String? nameEs;
  num? timeStart;
  num? intensity;
  num? minutes;

  Info({
    this.id,
    this.nameEn,
    this.nameEs,
    this.timeStart,
    this.intensity,
    this.minutes,
  });

  Info.fromJson(dynamic json) {
    id = json['id'];
    nameEn = json['name_en'];
    nameEs = json['name_es'];
    timeStart = json['timeStart'];
    intensity = json['intensity'];
    minutes = json['minutes'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name_en'] = nameEn;
    map['name_es'] = nameEs;
    map['timeStart'] = timeStart;
    map['intensity'] = intensity;
    map['minutes'] = minutes;
    return map;
  }
}
