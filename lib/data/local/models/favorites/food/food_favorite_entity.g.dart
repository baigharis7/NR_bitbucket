// HAND-CURATED — DO NOT REGENERATE WITHOUT RESTORING.
// Tolerant casts on read() handle Hive schema drift from older app versions
// that wrote different types at the same HiveField indices. Bare `as` casts
// crash on box open for those users and leave the food picker stuck on a
// loading spinner. After running build_runner, restore with `git checkout --`.

part of 'food_favorite_entity.dart';

class FoodFavoriteEntityAdapter extends TypeAdapter<FoodFavoriteEntity> {
  @override
  final int typeId = 40;

  @override
  FoodFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodFavoriteEntity(
      ingredients: _foodInList(fields[0]),
      drinks: _foodInList(fields[1]),
      comment: _strOrNull(fields[2]),
      mealTime: _int(fields[3]),
      title: _str(fields[4]),
      eventDate: _int(fields[5]),
      dish: _boolOrNull(fields[6]),
      isRoutine: _boolOrNull(fields[7]),
      daysOfWeek: _intListOrNull(fields[8]),
      eventId: _intOrNull(fields[9]),
      userId: _strOrNull(fields[10]),
      isFavorite: _boolOrNull(fields[11]),
      time: _strOrNull(fields[12]),
      timeZone: _strOrNull(fields[13]),
    );
  }

  static String _str(dynamic v) => v is String ? v : '';
  static String? _strOrNull(dynamic v) => v is String ? v : null;
  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
  static int? _intOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
  static bool? _boolOrNull(dynamic v) => v is bool ? v : null;
  static List<FoodInFavoriteEntity> _foodInList(dynamic v) {
    if (v is! List) return [];
    return v.whereType<FoodInFavoriteEntity>().toList();
  }
  static List<int>? _intListOrNull(dynamic v) {
    if (v == null) return null;
    if (v is! List) return null;
    return v.whereType<num>().map((n) => n.toInt()).toList();
  }

  @override
  void write(BinaryWriter writer, FoodFavoriteEntity obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.ingredients)
      ..writeByte(1)
      ..write(obj.drinks)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.mealTime)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.eventDate)
      ..writeByte(6)
      ..write(obj.dish)
      ..writeByte(7)
      ..write(obj.isRoutine)
      ..writeByte(8)
      ..write(obj.daysOfWeek)
      ..writeByte(9)
      ..write(obj.eventId)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.time)
      ..writeByte(13)
      ..write(obj.timeZone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodInFavoriteEntityAdapter extends TypeAdapter<FoodInFavoriteEntity> {
  @override
  final int typeId = 41;

  @override
  FoodInFavoriteEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodInFavoriteEntity(
      id: FoodFavoriteEntityAdapter._int(fields[0]),
      qty: FoodFavoriteEntityAdapter._int(fields[1]),
      unit: FoodFavoriteEntityAdapter._int(fields[2]),
      cookingMethod: FoodFavoriteEntityAdapter._int(fields[3]),
      unitsEquivalences: FoodFavoriteEntityAdapter._strOrNull(fields[4]),
      name_en: FoodFavoriteEntityAdapter._strOrNull(fields[5]),
      name_es: FoodFavoriteEntityAdapter._strOrNull(fields[6]),
      conversionFactor: FoodFavoriteEntityAdapter._intOrNull(fields[7]),
      usedOil: FoodFavoriteEntityAdapter._intOrNull(fields[8]),
    );
  }

  @override
  void write(BinaryWriter writer, FoodInFavoriteEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.qty)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.cookingMethod)
      ..writeByte(4)
      ..write(obj.unitsEquivalences)
      ..writeByte(5)
      ..write(obj.name_en)
      ..writeByte(6)
      ..write(obj.name_es)
      ..writeByte(7)
      ..write(obj.conversionFactor)
      ..writeByte(8)
      ..write(obj.usedOil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodInFavoriteEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodFavoriteEntity _$FoodFavoriteEntityFromJson(Map<String, dynamic> json) =>
    FoodFavoriteEntity(
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => FoodInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => FoodInFavoriteEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: (json['mealTime'] as num).toInt(),
      title: json['title'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      dish: json['dish'] as bool?,
      isRoutine: json['isRoutine'] as bool?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      eventId: (json['eventId'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      time: json['time'] as String?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$FoodFavoriteEntityToJson(FoodFavoriteEntity instance) =>
    <String, dynamic>{
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'title': instance.title,
      'eventDate': instance.eventDate,
      'dish': instance.dish,
      'isRoutine': instance.isRoutine,
      'daysOfWeek': instance.daysOfWeek,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'isFavorite': instance.isFavorite,
      'time': instance.time,
      'timeZone': instance.timeZone,
    };

FoodInFavoriteEntity _$FoodInFavoriteEntityFromJson(
        Map<String, dynamic> json) =>
    FoodInFavoriteEntity(
      id: (json['id'] as num).toInt(),
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      conversionFactor: (json['conversionFactor'] as num?)?.toInt(),
      usedOil: (json['usedOil'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FoodInFavoriteEntityToJson(
        FoodInFavoriteEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'conversionFactor': instance.conversionFactor,
      'usedOil': instance.usedOil,
    };
