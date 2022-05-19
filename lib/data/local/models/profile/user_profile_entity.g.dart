// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileEntityAdapter extends TypeAdapter<UserProfileEntity> {
  @override
  final int typeId = 0;

  @override
  UserProfileEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileEntity(
      userId: fields[0] as String?,
      commonName: fields[1] as String,
      birthDate: fields[2] as int,
      sex: fields[3] as int,
      occupationActivityFactor: fields[4] as double,
      physicalCharacteristics: fields[5] as PhysicalCharacteristics?,
      femaleCharacteristics: fields[6] as FemaleCharacteristics?,
      medicalSituation: fields[7] as MedicalSituation?,
      foodAversions: (fields[8] as List?)?.cast<int>(),
      dietType: fields[9] as int?,
      exclusions: fields[10] as Exclusions?,
      intolerances: (fields[11] as List?)?.cast<int>(),
      symptoms: fields[12] as String?,
      guts: fields[13] as int?,
      objectives: (fields[14] as List).cast<int>(),
      micronutrients: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileEntity obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.commonName)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.sex)
      ..writeByte(4)
      ..write(obj.occupationActivityFactor)
      ..writeByte(5)
      ..write(obj.physicalCharacteristics)
      ..writeByte(6)
      ..write(obj.femaleCharacteristics)
      ..writeByte(7)
      ..write(obj.medicalSituation)
      ..writeByte(8)
      ..write(obj.foodAversions)
      ..writeByte(9)
      ..write(obj.dietType)
      ..writeByte(10)
      ..write(obj.exclusions)
      ..writeByte(11)
      ..write(obj.intolerances)
      ..writeByte(12)
      ..write(obj.symptoms)
      ..writeByte(13)
      ..write(obj.guts)
      ..writeByte(14)
      ..write(obj.objectives)
      ..writeByte(15)
      ..write(obj.micronutrients);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicalSituationAdapter extends TypeAdapter<MedicalSituation> {
  @override
  final int typeId = 1;

  @override
  MedicalSituation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalSituation(
      commonDiseases: (fields[0] as List).cast<int>(),
      otherDiseases: (fields[1] as List).cast<String>(),
      underPharmaceuticalTreatment: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalSituation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.commonDiseases)
      ..writeByte(1)
      ..write(obj.otherDiseases)
      ..writeByte(2)
      ..write(obj.underPharmaceuticalTreatment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalSituationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhysicalCharacteristicsAdapter
    extends TypeAdapter<PhysicalCharacteristics> {
  @override
  final int typeId = 2;

  @override
  PhysicalCharacteristics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhysicalCharacteristics(
      height: fields[0] as int,
      weight: fields[1] as int,
      bodyFat: fields[2] as int?,
      waistMeasurement: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PhysicalCharacteristics obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.bodyFat)
      ..writeByte(3)
      ..write(obj.waistMeasurement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalCharacteristicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FemaleCharacteristicsAdapter extends TypeAdapter<FemaleCharacteristics> {
  @override
  final int typeId = 3;

  @override
  FemaleCharacteristics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FemaleCharacteristics(
      menstruation: fields[0] as Menstruation?,
    );
  }

  @override
  void write(BinaryWriter writer, FemaleCharacteristics obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.menstruation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FemaleCharacteristicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MenstruationAdapter extends TypeAdapter<Menstruation> {
  @override
  final int typeId = 4;

  @override
  Menstruation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Menstruation(
      regularity: fields[0] as int,
      daysOfCycle: fields[1] as int?,
      lastStartDate: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Menstruation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.regularity)
      ..writeByte(1)
      ..write(obj.daysOfCycle)
      ..writeByte(2)
      ..write(obj.lastStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenstruationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExclusionsAdapter extends TypeAdapter<Exclusions> {
  @override
  final int typeId = 5;

  @override
  Exclusions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exclusions(
      exclusions: (fields[0] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Exclusions obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.exclusions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExclusionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SexTypeAdapter extends TypeAdapter<SexType> {
  @override
  final int typeId = 6;

  @override
  SexType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SexType.male;
      case 1:
        return SexType.female;
      default:
        return SexType.male;
    }
  }

  @override
  void write(BinaryWriter writer, SexType obj) {
    switch (obj) {
      case SexType.male:
        writer.writeByte(0);
        break;
      case SexType.female:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SexTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MenstruationRegularityAdapter
    extends TypeAdapter<MenstruationRegularity> {
  @override
  final int typeId = 7;

  @override
  MenstruationRegularity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MenstruationRegularity.regular;
      case 1:
        return MenstruationRegularity.irregular;
      case 2:
        return MenstruationRegularity.nothing;
      default:
        return MenstruationRegularity.regular;
    }
  }

  @override
  void write(BinaryWriter writer, MenstruationRegularity obj) {
    switch (obj) {
      case MenstruationRegularity.regular:
        writer.writeByte(0);
        break;
      case MenstruationRegularity.irregular:
        writer.writeByte(1);
        break;
      case MenstruationRegularity.nothing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenstruationRegularityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
