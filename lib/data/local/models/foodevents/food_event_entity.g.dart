// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_event_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodEventEntityAdapter extends TypeAdapter<FoodEventEntity> {
  @override
  final int typeId = 8;

  @override
  FoodEventEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodEventEntity(
      fields[0] as String?,
      fields[1] as int?,
      (fields[2] as List?)?.cast<FoodInfo>(),
      fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodEventEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventDate)
      ..writeByte(2)
      ..write(obj.foodInfo)
      ..writeByte(3)
      ..write(obj.eventKcals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodEventEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodInfoAdapter extends TypeAdapter<FoodInfo> {
  @override
  final int typeId = 9;

  @override
  FoodInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodInfo(
      fields[0] as String?,
      fields[1] as int?,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as int?,
      fields[5] as EventInfo?,
      fields[6] as Params?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.group)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name_en)
      ..writeByte(3)
      ..write(obj.name_es)
      ..writeByte(4)
      ..write(obj.recommendable)
      ..writeByte(5)
      ..write(obj.eventInfo)
      ..writeByte(6)
      ..write(obj.params);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventInfoAdapter extends TypeAdapter<EventInfo> {
  @override
  final int typeId = 10;

  @override
  EventInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventInfo(
      fields[0] as int?,
      fields[1] as double?,
      fields[2] as int?,
      fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, EventInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cookingMethod)
      ..writeByte(1)
      ..write(obj.qty)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.waste);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParamsAdapter extends TypeAdapter<Params> {
  @override
  final int typeId = 11;

  @override
  Params read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Params(
      fields[0] as double?,
      fields[1] as double?,
      fields[2] as double?,
      fields[3] as double?,
      fields[4] as double?,
      fields[5] as double?,
      fields[6] as double?,
      fields[7] as double?,
      fields[8] as double?,
      fields[9] as double?,
      fields[10] as double?,
      fields[11] as double?,
      fields[12] as double?,
      fields[13] as double?,
      fields[14] as double?,
      fields[15] as double?,
      fields[16] as double?,
      fields[17] as double?,
      fields[18] as double?,
      fields[19] as double?,
      fields[20] as double?,
      fields[21] as double?,
      fields[22] as double?,
      fields[23] as double?,
      fields[24] as double?,
      fields[25] as double?,
      fields[26] as double?,
      fields[27] as double?,
      fields[28] as double?,
      fields[29] as double?,
      fields[30] as double?,
      fields[31] as double?,
      fields[32] as double?,
      fields[33] as double?,
      fields[34] as double?,
      fields[35] as double?,
      fields[36] as double?,
      fields[37] as double?,
      fields[38] as double?,
      fields[39] as double?,
      fields[40] as double?,
      fields[41] as double?,
      fields[42] as double?,
      fields[43] as double?,
      fields[44] as double?,
      fields[45] as double?,
      fields[46] as double?,
      fields[47] as double?,
      fields[48] as double?,
      fields[49] as double?,
      fields[50] as double?,
      fields[51] as double?,
      fields[52] as double?,
      fields[53] as double?,
      fields[54] as double?,
      fields[55] as double?,
      fields[56] as double?,
      fields[57] as double?,
      fields[58] as double?,
      fields[59] as double?,
      fields[60] as double?,
      fields[61] as double?,
      fields[62] as double?,
      fields[63] as double?,
      fields[64] as double?,
      fields[65] as double?,
      fields[66] as double?,
      fields[67] as double?,
      fields[69] as double?,
      fields[70] as double?,
      fields[71] as double?,
      fields[72] as double?,
      fields[73] as double?,
      fields[74] as double?,
      fields[75] as double?,
      fields[76] as double?,
      fields[77] as double?,
      fields[78] as double?,
      fields[79] as double?,
      fields[80] as double?,
      fields[81] as double?,
      fields[82] as double?,
      fields[83] as double?,
      fields[84] as double?,
      fields[85] as double?,
      fields[86] as double?,
      fields[87] as double?,
      fields[88] as double?,
      fields[89] as double?,
      fields[90] as double?,
      fields[91] as double?,
      fields[92] as double?,
      fields[93] as double?,
      fields[94] as double?,
      fields[104] as double?,
      fields[105] as double?,
      fields[95] as double?,
      fields[96] as double?,
      fields[97] as double?,
      fields[98] as double?,
      fields[99] as double?,
      fields[100] as double?,
      fields[101] as double?,
      fields[102] as double?,
      fields[103] as double?,
      fields[106] as double?,
      fields[107] as double?,
      fields[108] as double?,
      fields[109] as double?,
      fields[110] as double?,
      fields[111] as double?,
      fields[112] as double?,
      fields[113] as double?,
      fields[114] as double?,
      fields[115] as double?,
    )..sulfur = fields[68] as double?;
  }

  @override
  void write(BinaryWriter writer, Params obj) {
    writer
      ..writeByte(116)
      ..writeByte(0)
      ..write(obj.alanine)
      ..writeByte(1)
      ..write(obj.arginine)
      ..writeByte(2)
      ..write(obj.arsenic)
      ..writeByte(3)
      ..write(obj.ash)
      ..writeByte(4)
      ..write(obj.asparticAcid)
      ..writeByte(5)
      ..write(obj.benzoicAcid)
      ..writeByte(6)
      ..write(obj.betacaroteneVitA)
      ..writeByte(7)
      ..write(obj.c16_0)
      ..writeByte(8)
      ..write(obj.c18_0)
      ..writeByte(9)
      ..write(obj.c18_1N_9)
      ..writeByte(10)
      ..write(obj.c18_2N_6)
      ..writeByte(11)
      ..write(obj.c18_3N_3)
      ..writeByte(12)
      ..write(obj.cadmium)
      ..writeByte(13)
      ..write(obj.calcium)
      ..writeByte(14)
      ..write(obj.carbsAvailable)
      ..writeByte(15)
      ..write(obj.carbsByDiff)
      ..writeByte(16)
      ..write(obj.carbsDeclared)
      ..writeByte(17)
      ..write(obj.celulose)
      ..writeByte(18)
      ..write(obj.chromium)
      ..writeByte(19)
      ..write(obj.copper)
      ..writeByte(20)
      ..write(obj.cystine)
      ..writeByte(21)
      ..write(obj.dryMatter)
      ..writeByte(22)
      ..write(obj.energyKcal)
      ..writeByte(23)
      ..write(obj.energyKJ)
      ..writeByte(24)
      ..write(obj.fatTotal)
      ..writeByte(25)
      ..write(obj.fattyAcidConversionFactor)
      ..writeByte(26)
      ..write(obj.fattyAcidsTotal)
      ..writeByte(27)
      ..write(obj.fiber)
      ..writeByte(28)
      ..write(obj.fructose)
      ..writeByte(29)
      ..write(obj.glucose)
      ..writeByte(30)
      ..write(obj.glutamicAcid)
      ..writeByte(31)
      ..write(obj.glycine)
      ..writeByte(32)
      ..write(obj.hexose)
      ..writeByte(33)
      ..write(obj.histamine)
      ..writeByte(34)
      ..write(obj.histidine)
      ..writeByte(35)
      ..write(obj.hydroxyproline)
      ..writeByte(36)
      ..write(obj.iodine)
      ..writeByte(37)
      ..write(obj.iron)
      ..writeByte(38)
      ..write(obj.isoleucine)
      ..writeByte(39)
      ..write(obj.lead)
      ..writeByte(40)
      ..write(obj.leucine)
      ..writeByte(41)
      ..write(obj.lignin)
      ..writeByte(42)
      ..write(obj.lysine)
      ..writeByte(43)
      ..write(obj.magnesium)
      ..writeByte(44)
      ..write(obj.manganese)
      ..writeByte(45)
      ..write(obj.mercury)
      ..writeByte(46)
      ..write(obj.methionine)
      ..writeByte(47)
      ..write(obj.monosaccharidesTotal)
      ..writeByte(48)
      ..write(obj.nickel)
      ..writeByte(49)
      ..write(obj.nitro2protein)
      ..writeByte(50)
      ..write(obj.nitrogen)
      ..writeByte(51)
      ..write(obj.pentose)
      ..writeByte(52)
      ..write(obj.phenylalanine)
      ..writeByte(53)
      ..write(obj.phosphorus)
      ..writeByte(54)
      ..write(obj.potassium)
      ..writeByte(55)
      ..write(obj.proline)
      ..writeByte(56)
      ..write(obj.proteinLabel)
      ..writeByte(57)
      ..write(obj.proteinSci)
      ..writeByte(58)
      ..write(obj.selenium)
      ..writeByte(59)
      ..write(obj.serin)
      ..writeByte(60)
      ..write(obj.sodium)
      ..writeByte(61)
      ..write(obj.starch)
      ..writeByte(62)
      ..write(obj.sugarsTotal)
      ..writeByte(63)
      ..write(obj.sumMonoUnsat)
      ..writeByte(64)
      ..write(obj.sumN3FattyAcids)
      ..writeByte(65)
      ..write(obj.sumN6FattyAcids)
      ..writeByte(66)
      ..write(obj.sumPolyUnsat)
      ..writeByte(67)
      ..write(obj.sumSat)
      ..writeByte(68)
      ..write(obj.sulfur)
      ..writeByte(69)
      ..write(obj.threonine)
      ..writeByte(70)
      ..write(obj.tryptophan)
      ..writeByte(71)
      ..write(obj.tyrosine)
      ..writeByte(72)
      ..write(obj.uronicAcid)
      ..writeByte(73)
      ..write(obj.valin)
      ..writeByte(74)
      ..write(obj.vitA)
      ..writeByte(75)
      ..write(obj.vitB1)
      ..writeByte(76)
      ..write(obj.vitB2)
      ..writeByte(77)
      ..write(obj.vitB3)
      ..writeByte(78)
      ..write(obj.vitB3Eq)
      ..writeByte(79)
      ..write(obj.vitB5)
      ..writeByte(80)
      ..write(obj.vitB6)
      ..writeByte(81)
      ..write(obj.vitB7)
      ..writeByte(82)
      ..write(obj.vitB9)
      ..writeByte(83)
      ..write(obj.vitB9Free)
      ..writeByte(84)
      ..write(obj.vitB12)
      ..writeByte(85)
      ..write(obj.vitC)
      ..writeByte(86)
      ..write(obj.vitCL)
      ..writeByte(87)
      ..write(obj.vitCLDehydro)
      ..writeByte(88)
      ..write(obj.vitD)
      ..writeByte(89)
      ..write(obj.vitD2)
      ..writeByte(90)
      ..write(obj.vitD3)
      ..writeByte(91)
      ..write(obj.vitD_25hydroxi)
      ..writeByte(92)
      ..write(obj.vitD3_25hydroxi)
      ..writeByte(93)
      ..write(obj.vitE)
      ..writeByte(94)
      ..write(obj.vitE_alphaTP)
      ..writeByte(95)
      ..write(obj.other)
      ..writeByte(96)
      ..write(obj.saturated)
      ..writeByte(97)
      ..write(obj.monounsaturated)
      ..writeByte(98)
      ..write(obj.polyunsaturated)
      ..writeByte(99)
      ..write(obj.totalTrans)
      ..writeByte(100)
      ..write(obj.total)
      ..writeByte(101)
      ..write(obj.n3)
      ..writeByte(102)
      ..write(obj.n6)
      ..writeByte(103)
      ..write(obj.cholesterol)
      ..writeByte(104)
      ..write(obj.water)
      ..writeByte(105)
      ..write(obj.zinc)
      ..writeByte(106)
      ..write(obj.chloride)
      ..writeByte(107)
      ..write(obj.molybdenum)
      ..writeByte(108)
      ..write(obj.cobalt)
      ..writeByte(109)
      ..write(obj.fluoron)
      ..writeByte(110)
      ..write(obj.silicon)
      ..writeByte(111)
      ..write(obj.rubidium)
      ..writeByte(112)
      ..write(obj.aluminum)
      ..writeByte(113)
      ..write(obj.boron)
      ..writeByte(114)
      ..write(obj.bromine)
      ..writeByte(115)
      ..write(obj.arsenInorganic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParamsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEventEntity _$FoodEventEntityFromJson(Map<String, dynamic> json) =>
    FoodEventEntity(
      json['userId'] as String?,
      json['eventDate'] as int?,
      (json['foodInfo'] as List<dynamic>?)
          ?.map((e) => FoodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['eventKcals'] as int?,
    );

Map<String, dynamic> _$FoodEventEntityToJson(FoodEventEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'foodInfo': instance.foodInfo?.map((e) => e.toJson()).toList(),
      'eventKcals': instance.eventKcals,
    };

FoodInfo _$FoodInfoFromJson(Map<String, dynamic> json) => FoodInfo(
      json['group'] as String?,
      json['id'] as int?,
      json['name_en'] as String?,
      json['name_es'] as String?,
      json['recommendable'] as int?,
      json['eventInfo'] == null
          ? null
          : EventInfo.fromJson(json['eventInfo'] as Map<String, dynamic>),
      json['params'] == null
          ? null
          : Params.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodInfoToJson(FoodInfo instance) => <String, dynamic>{
      'group': instance.group,
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'recommendable': instance.recommendable,
      'eventInfo': instance.eventInfo?.toJson(),
      'params': instance.params?.toJson(),
    };

EventInfo _$EventInfoFromJson(Map<String, dynamic> json) => EventInfo(
      json['cookingMethod'] as int?,
      (json['qty'] as num?)?.toDouble(),
      json['unit'] as int?,
      (json['waste'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EventInfoToJson(EventInfo instance) => <String, dynamic>{
      'cookingMethod': instance.cookingMethod,
      'qty': instance.qty,
      'unit': instance.unit,
      'waste': instance.waste,
    };

Params _$ParamsFromJson(Map<String, dynamic> json) => Params(
      (json['alanine'] as num?)?.toDouble(),
      (json['arginine'] as num?)?.toDouble(),
      (json['arsenic'] as num?)?.toDouble(),
      (json['ash'] as num?)?.toDouble(),
      (json['asparticAcid'] as num?)?.toDouble(),
      (json['benzoicAcid'] as num?)?.toDouble(),
      (json['betacaroteneVitA'] as num?)?.toDouble(),
      (json['c16_0'] as num?)?.toDouble(),
      (json['c18_0'] as num?)?.toDouble(),
      (json['c18_1N_9'] as num?)?.toDouble(),
      (json['c18_2N_6'] as num?)?.toDouble(),
      (json['c18_3N_3'] as num?)?.toDouble(),
      (json['cadmium'] as num?)?.toDouble(),
      (json['calcium'] as num?)?.toDouble(),
      (json['carbsAvailable'] as num?)?.toDouble(),
      (json['carbsByDiff'] as num?)?.toDouble(),
      (json['carbsDeclared'] as num?)?.toDouble(),
      (json['celulose'] as num?)?.toDouble(),
      (json['chromium'] as num?)?.toDouble(),
      (json['copper'] as num?)?.toDouble(),
      (json['cystine'] as num?)?.toDouble(),
      (json['dryMatter'] as num?)?.toDouble(),
      (json['energyKcal'] as num?)?.toDouble(),
      (json['energyKJ'] as num?)?.toDouble(),
      (json['fatTotal'] as num?)?.toDouble(),
      (json['fattyAcidConversionFactor'] as num?)?.toDouble(),
      (json['fattyAcidsTotal'] as num?)?.toDouble(),
      (json['fiber'] as num?)?.toDouble(),
      (json['fructose'] as num?)?.toDouble(),
      (json['glucose'] as num?)?.toDouble(),
      (json['glutamicAcid'] as num?)?.toDouble(),
      (json['glycine'] as num?)?.toDouble(),
      (json['hexose'] as num?)?.toDouble(),
      (json['histamine'] as num?)?.toDouble(),
      (json['histidine'] as num?)?.toDouble(),
      (json['hydroxyproline'] as num?)?.toDouble(),
      (json['iodine'] as num?)?.toDouble(),
      (json['iron'] as num?)?.toDouble(),
      (json['isoleucine'] as num?)?.toDouble(),
      (json['lead'] as num?)?.toDouble(),
      (json['leucine'] as num?)?.toDouble(),
      (json['lignin'] as num?)?.toDouble(),
      (json['lysine'] as num?)?.toDouble(),
      (json['magnesium'] as num?)?.toDouble(),
      (json['manganese'] as num?)?.toDouble(),
      (json['mercury'] as num?)?.toDouble(),
      (json['methionine'] as num?)?.toDouble(),
      (json['monosaccharidesTotal'] as num?)?.toDouble(),
      (json['nickel'] as num?)?.toDouble(),
      (json['nitro2protein'] as num?)?.toDouble(),
      (json['nitrogen'] as num?)?.toDouble(),
      (json['pentose'] as num?)?.toDouble(),
      (json['phenylalanine'] as num?)?.toDouble(),
      (json['phosphorus'] as num?)?.toDouble(),
      (json['potassium'] as num?)?.toDouble(),
      (json['proline'] as num?)?.toDouble(),
      (json['proteinLabel'] as num?)?.toDouble(),
      (json['proteinSci'] as num?)?.toDouble(),
      (json['selenium'] as num?)?.toDouble(),
      (json['serin'] as num?)?.toDouble(),
      (json['sodium'] as num?)?.toDouble(),
      (json['starch'] as num?)?.toDouble(),
      (json['sugarsTotal'] as num?)?.toDouble(),
      (json['sumMonoUnsat'] as num?)?.toDouble(),
      (json['sumN3FattyAcids'] as num?)?.toDouble(),
      (json['sumN6FattyAcids'] as num?)?.toDouble(),
      (json['sumPolyUnsat'] as num?)?.toDouble(),
      (json['sumSat'] as num?)?.toDouble(),
      (json['threonine'] as num?)?.toDouble(),
      (json['tryptophan'] as num?)?.toDouble(),
      (json['tyrosine'] as num?)?.toDouble(),
      (json['uronicAcid'] as num?)?.toDouble(),
      (json['valin'] as num?)?.toDouble(),
      (json['vitA'] as num?)?.toDouble(),
      (json['vitB1'] as num?)?.toDouble(),
      (json['vitB2'] as num?)?.toDouble(),
      (json['vitB3'] as num?)?.toDouble(),
      (json['vitB3Eq'] as num?)?.toDouble(),
      (json['vitB5'] as num?)?.toDouble(),
      (json['vitB6'] as num?)?.toDouble(),
      (json['vitB7'] as num?)?.toDouble(),
      (json['vitB9'] as num?)?.toDouble(),
      (json['vitB9Free'] as num?)?.toDouble(),
      (json['vitB12'] as num?)?.toDouble(),
      (json['vitC'] as num?)?.toDouble(),
      (json['vitCL'] as num?)?.toDouble(),
      (json['vitCLDehydro'] as num?)?.toDouble(),
      (json['vitD'] as num?)?.toDouble(),
      (json['vitD2'] as num?)?.toDouble(),
      (json['vitD3'] as num?)?.toDouble(),
      (json['vitD_25hydroxi'] as num?)?.toDouble(),
      (json['vitD3_25hydroxi'] as num?)?.toDouble(),
      (json['vitE'] as num?)?.toDouble(),
      (json['vitE_alphaTP'] as num?)?.toDouble(),
      (json['water'] as num?)?.toDouble(),
      (json['zinc'] as num?)?.toDouble(),
      (json['other'] as num?)?.toDouble(),
      (json['saturated'] as num?)?.toDouble(),
      (json['monounsaturated'] as num?)?.toDouble(),
      (json['polyunsaturated'] as num?)?.toDouble(),
      (json['totalTrans'] as num?)?.toDouble(),
      (json['total'] as num?)?.toDouble(),
      (json['n3'] as num?)?.toDouble(),
      (json['n6'] as num?)?.toDouble(),
      (json['cholesterol'] as num?)?.toDouble(),
      (json['chloride'] as num?)?.toDouble(),
      (json['molybdenum'] as num?)?.toDouble(),
      (json['cobalt'] as num?)?.toDouble(),
      (json['fluoron'] as num?)?.toDouble(),
      (json['silicon'] as num?)?.toDouble(),
      (json['rubidium'] as num?)?.toDouble(),
      (json['aluminum'] as num?)?.toDouble(),
      (json['boron'] as num?)?.toDouble(),
      (json['bromine'] as num?)?.toDouble(),
      (json['arsenInorganic'] as num?)?.toDouble(),
    )..sulfur = (json['sulfur'] as num?)?.toDouble();

Map<String, dynamic> _$ParamsToJson(Params instance) => <String, dynamic>{
      'alanine': instance.alanine,
      'arginine': instance.arginine,
      'arsenic': instance.arsenic,
      'ash': instance.ash,
      'asparticAcid': instance.asparticAcid,
      'benzoicAcid': instance.benzoicAcid,
      'betacaroteneVitA': instance.betacaroteneVitA,
      'c16_0': instance.c16_0,
      'c18_0': instance.c18_0,
      'c18_1N_9': instance.c18_1N_9,
      'c18_2N_6': instance.c18_2N_6,
      'c18_3N_3': instance.c18_3N_3,
      'cadmium': instance.cadmium,
      'calcium': instance.calcium,
      'carbsAvailable': instance.carbsAvailable,
      'carbsByDiff': instance.carbsByDiff,
      'carbsDeclared': instance.carbsDeclared,
      'celulose': instance.celulose,
      'chromium': instance.chromium,
      'copper': instance.copper,
      'cystine': instance.cystine,
      'dryMatter': instance.dryMatter,
      'energyKcal': instance.energyKcal,
      'energyKJ': instance.energyKJ,
      'fatTotal': instance.fatTotal,
      'fattyAcidConversionFactor': instance.fattyAcidConversionFactor,
      'fattyAcidsTotal': instance.fattyAcidsTotal,
      'fiber': instance.fiber,
      'fructose': instance.fructose,
      'glucose': instance.glucose,
      'glutamicAcid': instance.glutamicAcid,
      'glycine': instance.glycine,
      'hexose': instance.hexose,
      'histamine': instance.histamine,
      'histidine': instance.histidine,
      'hydroxyproline': instance.hydroxyproline,
      'iodine': instance.iodine,
      'iron': instance.iron,
      'isoleucine': instance.isoleucine,
      'lead': instance.lead,
      'leucine': instance.leucine,
      'lignin': instance.lignin,
      'lysine': instance.lysine,
      'magnesium': instance.magnesium,
      'manganese': instance.manganese,
      'mercury': instance.mercury,
      'methionine': instance.methionine,
      'monosaccharidesTotal': instance.monosaccharidesTotal,
      'nickel': instance.nickel,
      'nitro2protein': instance.nitro2protein,
      'nitrogen': instance.nitrogen,
      'pentose': instance.pentose,
      'phenylalanine': instance.phenylalanine,
      'phosphorus': instance.phosphorus,
      'potassium': instance.potassium,
      'proline': instance.proline,
      'proteinLabel': instance.proteinLabel,
      'proteinSci': instance.proteinSci,
      'selenium': instance.selenium,
      'serin': instance.serin,
      'sodium': instance.sodium,
      'starch': instance.starch,
      'sugarsTotal': instance.sugarsTotal,
      'sumMonoUnsat': instance.sumMonoUnsat,
      'sumN3FattyAcids': instance.sumN3FattyAcids,
      'sumN6FattyAcids': instance.sumN6FattyAcids,
      'sumPolyUnsat': instance.sumPolyUnsat,
      'sumSat': instance.sumSat,
      'sulfur': instance.sulfur,
      'threonine': instance.threonine,
      'tryptophan': instance.tryptophan,
      'tyrosine': instance.tyrosine,
      'uronicAcid': instance.uronicAcid,
      'valin': instance.valin,
      'vitA': instance.vitA,
      'vitB1': instance.vitB1,
      'vitB2': instance.vitB2,
      'vitB3': instance.vitB3,
      'vitB3Eq': instance.vitB3Eq,
      'vitB5': instance.vitB5,
      'vitB6': instance.vitB6,
      'vitB7': instance.vitB7,
      'vitB9': instance.vitB9,
      'vitB9Free': instance.vitB9Free,
      'vitB12': instance.vitB12,
      'vitC': instance.vitC,
      'vitCL': instance.vitCL,
      'vitCLDehydro': instance.vitCLDehydro,
      'vitD': instance.vitD,
      'vitD2': instance.vitD2,
      'vitD3': instance.vitD3,
      'vitD_25hydroxi': instance.vitD_25hydroxi,
      'vitD3_25hydroxi': instance.vitD3_25hydroxi,
      'vitE': instance.vitE,
      'vitE_alphaTP': instance.vitE_alphaTP,
      'other': instance.other,
      'saturated': instance.saturated,
      'monounsaturated': instance.monounsaturated,
      'polyunsaturated': instance.polyunsaturated,
      'totalTrans': instance.totalTrans,
      'total': instance.total,
      'n3': instance.n3,
      'n6': instance.n6,
      'cholesterol': instance.cholesterol,
      'water': instance.water,
      'zinc': instance.zinc,
      'chloride': instance.chloride,
      'molybdenum': instance.molybdenum,
      'cobalt': instance.cobalt,
      'fluoron': instance.fluoron,
      'silicon': instance.silicon,
      'rubidium': instance.rubidium,
      'aluminum': instance.aluminum,
      'boron': instance.boron,
      'bromine': instance.bromine,
      'arsenInorganic': instance.arsenInorganic,
    };
