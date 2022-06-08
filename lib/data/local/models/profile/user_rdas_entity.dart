import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'user_rdas_entity.g.dart';

@HiveType(typeId: HiveTypeIds.userRdasEntity)
@JsonSerializable(explicitToJson: true)
class UserRdasEntity {
  @HiveField(0) String n;
  @HiveField(1) double rda;
  @HiveField(2) double ul;

  static const boxName = 'userRdas';

  UserRdasEntity({required this.n, required this.rda, required this.ul});

  factory UserRdasEntity.fromJson(Map<String, dynamic> json) => _$UserRdasEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserRdasEntityToJson(this);
}