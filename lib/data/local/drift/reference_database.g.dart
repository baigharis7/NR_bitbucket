// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_database.dart';

// ignore_for_file: type=lint
class $NutrientCompositionsTable extends NutrientCompositions
    with TableInfo<$NutrientCompositionsTable, NutrientComposition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutrientCompositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
      'food_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isFoodMeta = const VerificationMeta('isFood');
  @override
  late final GeneratedColumn<int> isFood = GeneratedColumn<int>(
      'is_food', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
      'group', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
      'name_es', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _recommendableMeta =
      const VerificationMeta('recommendable');
  @override
  late final GeneratedColumn<int> recommendable = GeneratedColumn<int>(
      'recommendable', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _freeSugarMeta =
      const VerificationMeta('freeSugar');
  @override
  late final GeneratedColumn<String> freeSugar = GeneratedColumn<String>(
      'free_sugar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
      'params', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recGroupMeta =
      const VerificationMeta('recGroup');
  @override
  late final GeneratedColumn<int> recGroup = GeneratedColumn<int>(
      'rec_group', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _exchangePortionMeta =
      const VerificationMeta('exchangePortion');
  @override
  late final GeneratedColumn<double> exchangePortion = GeneratedColumn<double>(
      'exchange_portion', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _allergiesExclusionsMeta =
      const VerificationMeta('allergiesExclusions');
  @override
  late final GeneratedColumn<String> allergiesExclusions =
      GeneratedColumn<String>('allergies_exclusions', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _intolerancesMeta =
      const VerificationMeta('intolerances');
  @override
  late final GeneratedColumn<String> intolerances = GeneratedColumn<String>(
      'intolerances', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _diseasesMeta =
      const VerificationMeta('diseases');
  @override
  late final GeneratedColumn<String> diseases = GeneratedColumn<String>(
      'diseases', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _gutsMeta = const VerificationMeta('guts');
  @override
  late final GeneratedColumn<int> guts = GeneratedColumn<int>(
      'guts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<int> rarity = GeneratedColumn<int>(
      'rarity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _novaClassificationMeta =
      const VerificationMeta('novaClassification');
  @override
  late final GeneratedColumn<int> novaClassification = GeneratedColumn<int>(
      'nova_classification', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _includedMeta =
      const VerificationMeta('included');
  @override
  late final GeneratedColumn<int> included = GeneratedColumn<int>(
      'included', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        foodId,
        isFood,
        group,
        nameEn,
        nameEs,
        recommendable,
        freeSugar,
        params,
        recGroup,
        exchangePortion,
        allergiesExclusions,
        intolerances,
        diseases,
        guts,
        rarity,
        novaClassification,
        included
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrient_compositions';
  @override
  VerificationContext validateIntegrity(
      Insertable<NutrientComposition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('is_food')) {
      context.handle(_isFoodMeta,
          isFood.isAcceptableOrUnknown(data['is_food']!, _isFoodMeta));
    } else if (isInserting) {
      context.missing(_isFoodMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
          _groupMeta, group.isAcceptableOrUnknown(data['group']!, _groupMeta));
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    }
    if (data.containsKey('name_es')) {
      context.handle(_nameEsMeta,
          nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta));
    }
    if (data.containsKey('recommendable')) {
      context.handle(
          _recommendableMeta,
          recommendable.isAcceptableOrUnknown(
              data['recommendable']!, _recommendableMeta));
    }
    if (data.containsKey('free_sugar')) {
      context.handle(_freeSugarMeta,
          freeSugar.isAcceptableOrUnknown(data['free_sugar']!, _freeSugarMeta));
    }
    if (data.containsKey('params')) {
      context.handle(_paramsMeta,
          params.isAcceptableOrUnknown(data['params']!, _paramsMeta));
    } else if (isInserting) {
      context.missing(_paramsMeta);
    }
    if (data.containsKey('rec_group')) {
      context.handle(_recGroupMeta,
          recGroup.isAcceptableOrUnknown(data['rec_group']!, _recGroupMeta));
    }
    if (data.containsKey('exchange_portion')) {
      context.handle(
          _exchangePortionMeta,
          exchangePortion.isAcceptableOrUnknown(
              data['exchange_portion']!, _exchangePortionMeta));
    }
    if (data.containsKey('allergies_exclusions')) {
      context.handle(
          _allergiesExclusionsMeta,
          allergiesExclusions.isAcceptableOrUnknown(
              data['allergies_exclusions']!, _allergiesExclusionsMeta));
    }
    if (data.containsKey('intolerances')) {
      context.handle(
          _intolerancesMeta,
          intolerances.isAcceptableOrUnknown(
              data['intolerances']!, _intolerancesMeta));
    }
    if (data.containsKey('diseases')) {
      context.handle(_diseasesMeta,
          diseases.isAcceptableOrUnknown(data['diseases']!, _diseasesMeta));
    }
    if (data.containsKey('guts')) {
      context.handle(
          _gutsMeta, guts.isAcceptableOrUnknown(data['guts']!, _gutsMeta));
    }
    if (data.containsKey('rarity')) {
      context.handle(_rarityMeta,
          rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta));
    }
    if (data.containsKey('nova_classification')) {
      context.handle(
          _novaClassificationMeta,
          novaClassification.isAcceptableOrUnknown(
              data['nova_classification']!, _novaClassificationMeta));
    }
    if (data.containsKey('included')) {
      context.handle(_includedMeta,
          included.isAcceptableOrUnknown(data['included']!, _includedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {foodId};
  @override
  NutrientComposition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutrientComposition(
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_id'])!,
      isFood: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_food'])!,
      group: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      nameEs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_es'])!,
      recommendable: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recommendable'])!,
      freeSugar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}free_sugar']),
      params: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}params'])!,
      recGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rec_group'])!,
      exchangePortion: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}exchange_portion'])!,
      allergiesExclusions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}allergies_exclusions'])!,
      intolerances: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intolerances'])!,
      diseases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diseases'])!,
      guts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}guts'])!,
      rarity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rarity'])!,
      novaClassification: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}nova_classification'])!,
      included: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}included'])!,
    );
  }

  @override
  $NutrientCompositionsTable createAlias(String alias) {
    return $NutrientCompositionsTable(attachedDatabase, alias);
  }
}

class NutrientComposition extends DataClass
    implements Insertable<NutrientComposition> {
  final int foodId;
  final int isFood;
  final String group;
  final String nameEn;
  final String nameEs;
  final int recommendable;
  final String? freeSugar;
  final String params;
  final int recGroup;
  final double exchangePortion;
  final String allergiesExclusions;
  final String intolerances;
  final String diseases;
  final int guts;
  final int rarity;
  final int novaClassification;
  final int included;
  const NutrientComposition(
      {required this.foodId,
      required this.isFood,
      required this.group,
      required this.nameEn,
      required this.nameEs,
      required this.recommendable,
      this.freeSugar,
      required this.params,
      required this.recGroup,
      required this.exchangePortion,
      required this.allergiesExclusions,
      required this.intolerances,
      required this.diseases,
      required this.guts,
      required this.rarity,
      required this.novaClassification,
      required this.included});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<int>(foodId);
    map['is_food'] = Variable<int>(isFood);
    map['group'] = Variable<String>(group);
    map['name_en'] = Variable<String>(nameEn);
    map['name_es'] = Variable<String>(nameEs);
    map['recommendable'] = Variable<int>(recommendable);
    if (!nullToAbsent || freeSugar != null) {
      map['free_sugar'] = Variable<String>(freeSugar);
    }
    map['params'] = Variable<String>(params);
    map['rec_group'] = Variable<int>(recGroup);
    map['exchange_portion'] = Variable<double>(exchangePortion);
    map['allergies_exclusions'] = Variable<String>(allergiesExclusions);
    map['intolerances'] = Variable<String>(intolerances);
    map['diseases'] = Variable<String>(diseases);
    map['guts'] = Variable<int>(guts);
    map['rarity'] = Variable<int>(rarity);
    map['nova_classification'] = Variable<int>(novaClassification);
    map['included'] = Variable<int>(included);
    return map;
  }

  NutrientCompositionsCompanion toCompanion(bool nullToAbsent) {
    return NutrientCompositionsCompanion(
      foodId: Value(foodId),
      isFood: Value(isFood),
      group: Value(group),
      nameEn: Value(nameEn),
      nameEs: Value(nameEs),
      recommendable: Value(recommendable),
      freeSugar: freeSugar == null && nullToAbsent
          ? const Value.absent()
          : Value(freeSugar),
      params: Value(params),
      recGroup: Value(recGroup),
      exchangePortion: Value(exchangePortion),
      allergiesExclusions: Value(allergiesExclusions),
      intolerances: Value(intolerances),
      diseases: Value(diseases),
      guts: Value(guts),
      rarity: Value(rarity),
      novaClassification: Value(novaClassification),
      included: Value(included),
    );
  }

  factory NutrientComposition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutrientComposition(
      foodId: serializer.fromJson<int>(json['foodId']),
      isFood: serializer.fromJson<int>(json['isFood']),
      group: serializer.fromJson<String>(json['group']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      recommendable: serializer.fromJson<int>(json['recommendable']),
      freeSugar: serializer.fromJson<String?>(json['freeSugar']),
      params: serializer.fromJson<String>(json['params']),
      recGroup: serializer.fromJson<int>(json['recGroup']),
      exchangePortion: serializer.fromJson<double>(json['exchangePortion']),
      allergiesExclusions:
          serializer.fromJson<String>(json['allergiesExclusions']),
      intolerances: serializer.fromJson<String>(json['intolerances']),
      diseases: serializer.fromJson<String>(json['diseases']),
      guts: serializer.fromJson<int>(json['guts']),
      rarity: serializer.fromJson<int>(json['rarity']),
      novaClassification: serializer.fromJson<int>(json['novaClassification']),
      included: serializer.fromJson<int>(json['included']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodId': serializer.toJson<int>(foodId),
      'isFood': serializer.toJson<int>(isFood),
      'group': serializer.toJson<String>(group),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameEs': serializer.toJson<String>(nameEs),
      'recommendable': serializer.toJson<int>(recommendable),
      'freeSugar': serializer.toJson<String?>(freeSugar),
      'params': serializer.toJson<String>(params),
      'recGroup': serializer.toJson<int>(recGroup),
      'exchangePortion': serializer.toJson<double>(exchangePortion),
      'allergiesExclusions': serializer.toJson<String>(allergiesExclusions),
      'intolerances': serializer.toJson<String>(intolerances),
      'diseases': serializer.toJson<String>(diseases),
      'guts': serializer.toJson<int>(guts),
      'rarity': serializer.toJson<int>(rarity),
      'novaClassification': serializer.toJson<int>(novaClassification),
      'included': serializer.toJson<int>(included),
    };
  }

  NutrientComposition copyWith(
          {int? foodId,
          int? isFood,
          String? group,
          String? nameEn,
          String? nameEs,
          int? recommendable,
          Value<String?> freeSugar = const Value.absent(),
          String? params,
          int? recGroup,
          double? exchangePortion,
          String? allergiesExclusions,
          String? intolerances,
          String? diseases,
          int? guts,
          int? rarity,
          int? novaClassification,
          int? included}) =>
      NutrientComposition(
        foodId: foodId ?? this.foodId,
        isFood: isFood ?? this.isFood,
        group: group ?? this.group,
        nameEn: nameEn ?? this.nameEn,
        nameEs: nameEs ?? this.nameEs,
        recommendable: recommendable ?? this.recommendable,
        freeSugar: freeSugar.present ? freeSugar.value : this.freeSugar,
        params: params ?? this.params,
        recGroup: recGroup ?? this.recGroup,
        exchangePortion: exchangePortion ?? this.exchangePortion,
        allergiesExclusions: allergiesExclusions ?? this.allergiesExclusions,
        intolerances: intolerances ?? this.intolerances,
        diseases: diseases ?? this.diseases,
        guts: guts ?? this.guts,
        rarity: rarity ?? this.rarity,
        novaClassification: novaClassification ?? this.novaClassification,
        included: included ?? this.included,
      );
  NutrientComposition copyWithCompanion(NutrientCompositionsCompanion data) {
    return NutrientComposition(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      isFood: data.isFood.present ? data.isFood.value : this.isFood,
      group: data.group.present ? data.group.value : this.group,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      recommendable: data.recommendable.present
          ? data.recommendable.value
          : this.recommendable,
      freeSugar: data.freeSugar.present ? data.freeSugar.value : this.freeSugar,
      params: data.params.present ? data.params.value : this.params,
      recGroup: data.recGroup.present ? data.recGroup.value : this.recGroup,
      exchangePortion: data.exchangePortion.present
          ? data.exchangePortion.value
          : this.exchangePortion,
      allergiesExclusions: data.allergiesExclusions.present
          ? data.allergiesExclusions.value
          : this.allergiesExclusions,
      intolerances: data.intolerances.present
          ? data.intolerances.value
          : this.intolerances,
      diseases: data.diseases.present ? data.diseases.value : this.diseases,
      guts: data.guts.present ? data.guts.value : this.guts,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      novaClassification: data.novaClassification.present
          ? data.novaClassification.value
          : this.novaClassification,
      included: data.included.present ? data.included.value : this.included,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutrientComposition(')
          ..write('foodId: $foodId, ')
          ..write('isFood: $isFood, ')
          ..write('group: $group, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('recommendable: $recommendable, ')
          ..write('freeSugar: $freeSugar, ')
          ..write('params: $params, ')
          ..write('recGroup: $recGroup, ')
          ..write('exchangePortion: $exchangePortion, ')
          ..write('allergiesExclusions: $allergiesExclusions, ')
          ..write('intolerances: $intolerances, ')
          ..write('diseases: $diseases, ')
          ..write('guts: $guts, ')
          ..write('rarity: $rarity, ')
          ..write('novaClassification: $novaClassification, ')
          ..write('included: $included')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      foodId,
      isFood,
      group,
      nameEn,
      nameEs,
      recommendable,
      freeSugar,
      params,
      recGroup,
      exchangePortion,
      allergiesExclusions,
      intolerances,
      diseases,
      guts,
      rarity,
      novaClassification,
      included);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutrientComposition &&
          other.foodId == this.foodId &&
          other.isFood == this.isFood &&
          other.group == this.group &&
          other.nameEn == this.nameEn &&
          other.nameEs == this.nameEs &&
          other.recommendable == this.recommendable &&
          other.freeSugar == this.freeSugar &&
          other.params == this.params &&
          other.recGroup == this.recGroup &&
          other.exchangePortion == this.exchangePortion &&
          other.allergiesExclusions == this.allergiesExclusions &&
          other.intolerances == this.intolerances &&
          other.diseases == this.diseases &&
          other.guts == this.guts &&
          other.rarity == this.rarity &&
          other.novaClassification == this.novaClassification &&
          other.included == this.included);
}

class NutrientCompositionsCompanion
    extends UpdateCompanion<NutrientComposition> {
  final Value<int> foodId;
  final Value<int> isFood;
  final Value<String> group;
  final Value<String> nameEn;
  final Value<String> nameEs;
  final Value<int> recommendable;
  final Value<String?> freeSugar;
  final Value<String> params;
  final Value<int> recGroup;
  final Value<double> exchangePortion;
  final Value<String> allergiesExclusions;
  final Value<String> intolerances;
  final Value<String> diseases;
  final Value<int> guts;
  final Value<int> rarity;
  final Value<int> novaClassification;
  final Value<int> included;
  const NutrientCompositionsCompanion({
    this.foodId = const Value.absent(),
    this.isFood = const Value.absent(),
    this.group = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.recommendable = const Value.absent(),
    this.freeSugar = const Value.absent(),
    this.params = const Value.absent(),
    this.recGroup = const Value.absent(),
    this.exchangePortion = const Value.absent(),
    this.allergiesExclusions = const Value.absent(),
    this.intolerances = const Value.absent(),
    this.diseases = const Value.absent(),
    this.guts = const Value.absent(),
    this.rarity = const Value.absent(),
    this.novaClassification = const Value.absent(),
    this.included = const Value.absent(),
  });
  NutrientCompositionsCompanion.insert({
    this.foodId = const Value.absent(),
    required int isFood,
    this.group = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.recommendable = const Value.absent(),
    this.freeSugar = const Value.absent(),
    required String params,
    this.recGroup = const Value.absent(),
    this.exchangePortion = const Value.absent(),
    this.allergiesExclusions = const Value.absent(),
    this.intolerances = const Value.absent(),
    this.diseases = const Value.absent(),
    this.guts = const Value.absent(),
    this.rarity = const Value.absent(),
    this.novaClassification = const Value.absent(),
    this.included = const Value.absent(),
  })  : isFood = Value(isFood),
        params = Value(params);
  static Insertable<NutrientComposition> custom({
    Expression<int>? foodId,
    Expression<int>? isFood,
    Expression<String>? group,
    Expression<String>? nameEn,
    Expression<String>? nameEs,
    Expression<int>? recommendable,
    Expression<String>? freeSugar,
    Expression<String>? params,
    Expression<int>? recGroup,
    Expression<double>? exchangePortion,
    Expression<String>? allergiesExclusions,
    Expression<String>? intolerances,
    Expression<String>? diseases,
    Expression<int>? guts,
    Expression<int>? rarity,
    Expression<int>? novaClassification,
    Expression<int>? included,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (isFood != null) 'is_food': isFood,
      if (group != null) 'group': group,
      if (nameEn != null) 'name_en': nameEn,
      if (nameEs != null) 'name_es': nameEs,
      if (recommendable != null) 'recommendable': recommendable,
      if (freeSugar != null) 'free_sugar': freeSugar,
      if (params != null) 'params': params,
      if (recGroup != null) 'rec_group': recGroup,
      if (exchangePortion != null) 'exchange_portion': exchangePortion,
      if (allergiesExclusions != null)
        'allergies_exclusions': allergiesExclusions,
      if (intolerances != null) 'intolerances': intolerances,
      if (diseases != null) 'diseases': diseases,
      if (guts != null) 'guts': guts,
      if (rarity != null) 'rarity': rarity,
      if (novaClassification != null) 'nova_classification': novaClassification,
      if (included != null) 'included': included,
    });
  }

  NutrientCompositionsCompanion copyWith(
      {Value<int>? foodId,
      Value<int>? isFood,
      Value<String>? group,
      Value<String>? nameEn,
      Value<String>? nameEs,
      Value<int>? recommendable,
      Value<String?>? freeSugar,
      Value<String>? params,
      Value<int>? recGroup,
      Value<double>? exchangePortion,
      Value<String>? allergiesExclusions,
      Value<String>? intolerances,
      Value<String>? diseases,
      Value<int>? guts,
      Value<int>? rarity,
      Value<int>? novaClassification,
      Value<int>? included}) {
    return NutrientCompositionsCompanion(
      foodId: foodId ?? this.foodId,
      isFood: isFood ?? this.isFood,
      group: group ?? this.group,
      nameEn: nameEn ?? this.nameEn,
      nameEs: nameEs ?? this.nameEs,
      recommendable: recommendable ?? this.recommendable,
      freeSugar: freeSugar ?? this.freeSugar,
      params: params ?? this.params,
      recGroup: recGroup ?? this.recGroup,
      exchangePortion: exchangePortion ?? this.exchangePortion,
      allergiesExclusions: allergiesExclusions ?? this.allergiesExclusions,
      intolerances: intolerances ?? this.intolerances,
      diseases: diseases ?? this.diseases,
      guts: guts ?? this.guts,
      rarity: rarity ?? this.rarity,
      novaClassification: novaClassification ?? this.novaClassification,
      included: included ?? this.included,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (isFood.present) {
      map['is_food'] = Variable<int>(isFood.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (recommendable.present) {
      map['recommendable'] = Variable<int>(recommendable.value);
    }
    if (freeSugar.present) {
      map['free_sugar'] = Variable<String>(freeSugar.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (recGroup.present) {
      map['rec_group'] = Variable<int>(recGroup.value);
    }
    if (exchangePortion.present) {
      map['exchange_portion'] = Variable<double>(exchangePortion.value);
    }
    if (allergiesExclusions.present) {
      map['allergies_exclusions'] = Variable<String>(allergiesExclusions.value);
    }
    if (intolerances.present) {
      map['intolerances'] = Variable<String>(intolerances.value);
    }
    if (diseases.present) {
      map['diseases'] = Variable<String>(diseases.value);
    }
    if (guts.present) {
      map['guts'] = Variable<int>(guts.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<int>(rarity.value);
    }
    if (novaClassification.present) {
      map['nova_classification'] = Variable<int>(novaClassification.value);
    }
    if (included.present) {
      map['included'] = Variable<int>(included.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutrientCompositionsCompanion(')
          ..write('foodId: $foodId, ')
          ..write('isFood: $isFood, ')
          ..write('group: $group, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('recommendable: $recommendable, ')
          ..write('freeSugar: $freeSugar, ')
          ..write('params: $params, ')
          ..write('recGroup: $recGroup, ')
          ..write('exchangePortion: $exchangePortion, ')
          ..write('allergiesExclusions: $allergiesExclusions, ')
          ..write('intolerances: $intolerances, ')
          ..write('diseases: $diseases, ')
          ..write('guts: $guts, ')
          ..write('rarity: $rarity, ')
          ..write('novaClassification: $novaClassification, ')
          ..write('included: $included')
          ..write(')'))
        .toString();
  }
}

class $NutrientLossesTable extends NutrientLosses
    with TableInfo<$NutrientLossesTable, NutrientLossEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutrientLossesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cookingMethodIdMeta =
      const VerificationMeta('cookingMethodId');
  @override
  late final GeneratedColumn<int> cookingMethodId = GeneratedColumn<int>(
      'cooking_method_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lossesMeta = const VerificationMeta('losses');
  @override
  late final GeneratedColumn<String> losses = GeneratedColumn<String>(
      'losses', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cookingMethodId, losses];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrient_losses';
  @override
  VerificationContext validateIntegrity(Insertable<NutrientLossEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cooking_method_id')) {
      context.handle(
          _cookingMethodIdMeta,
          cookingMethodId.isAcceptableOrUnknown(
              data['cooking_method_id']!, _cookingMethodIdMeta));
    }
    if (data.containsKey('losses')) {
      context.handle(_lossesMeta,
          losses.isAcceptableOrUnknown(data['losses']!, _lossesMeta));
    } else if (isInserting) {
      context.missing(_lossesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cookingMethodId};
  @override
  NutrientLossEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutrientLossEntry(
      cookingMethodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cooking_method_id'])!,
      losses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}losses'])!,
    );
  }

  @override
  $NutrientLossesTable createAlias(String alias) {
    return $NutrientLossesTable(attachedDatabase, alias);
  }
}

class NutrientLossEntry extends DataClass
    implements Insertable<NutrientLossEntry> {
  final int cookingMethodId;
  final String losses;
  const NutrientLossEntry(
      {required this.cookingMethodId, required this.losses});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cooking_method_id'] = Variable<int>(cookingMethodId);
    map['losses'] = Variable<String>(losses);
    return map;
  }

  NutrientLossesCompanion toCompanion(bool nullToAbsent) {
    return NutrientLossesCompanion(
      cookingMethodId: Value(cookingMethodId),
      losses: Value(losses),
    );
  }

  factory NutrientLossEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutrientLossEntry(
      cookingMethodId: serializer.fromJson<int>(json['cookingMethodId']),
      losses: serializer.fromJson<String>(json['losses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cookingMethodId': serializer.toJson<int>(cookingMethodId),
      'losses': serializer.toJson<String>(losses),
    };
  }

  NutrientLossEntry copyWith({int? cookingMethodId, String? losses}) =>
      NutrientLossEntry(
        cookingMethodId: cookingMethodId ?? this.cookingMethodId,
        losses: losses ?? this.losses,
      );
  NutrientLossEntry copyWithCompanion(NutrientLossesCompanion data) {
    return NutrientLossEntry(
      cookingMethodId: data.cookingMethodId.present
          ? data.cookingMethodId.value
          : this.cookingMethodId,
      losses: data.losses.present ? data.losses.value : this.losses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutrientLossEntry(')
          ..write('cookingMethodId: $cookingMethodId, ')
          ..write('losses: $losses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cookingMethodId, losses);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutrientLossEntry &&
          other.cookingMethodId == this.cookingMethodId &&
          other.losses == this.losses);
}

class NutrientLossesCompanion extends UpdateCompanion<NutrientLossEntry> {
  final Value<int> cookingMethodId;
  final Value<String> losses;
  const NutrientLossesCompanion({
    this.cookingMethodId = const Value.absent(),
    this.losses = const Value.absent(),
  });
  NutrientLossesCompanion.insert({
    this.cookingMethodId = const Value.absent(),
    required String losses,
  }) : losses = Value(losses);
  static Insertable<NutrientLossEntry> custom({
    Expression<int>? cookingMethodId,
    Expression<String>? losses,
  }) {
    return RawValuesInsertable({
      if (cookingMethodId != null) 'cooking_method_id': cookingMethodId,
      if (losses != null) 'losses': losses,
    });
  }

  NutrientLossesCompanion copyWith(
      {Value<int>? cookingMethodId, Value<String>? losses}) {
    return NutrientLossesCompanion(
      cookingMethodId: cookingMethodId ?? this.cookingMethodId,
      losses: losses ?? this.losses,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cookingMethodId.present) {
      map['cooking_method_id'] = Variable<int>(cookingMethodId.value);
    }
    if (losses.present) {
      map['losses'] = Variable<String>(losses.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutrientLossesCompanion(')
          ..write('cookingMethodId: $cookingMethodId, ')
          ..write('losses: $losses')
          ..write(')'))
        .toString();
  }
}

class $CookingMethodOilsTable extends CookingMethodOils
    with TableInfo<$CookingMethodOilsTable, CookingMethodOil> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookingMethodOilsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cookingMethodIdMeta =
      const VerificationMeta('cookingMethodId');
  @override
  late final GeneratedColumn<int> cookingMethodId = GeneratedColumn<int>(
      'cooking_method_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cookingMethodId, percentage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cooking_method_oils';
  @override
  VerificationContext validateIntegrity(Insertable<CookingMethodOil> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cooking_method_id')) {
      context.handle(
          _cookingMethodIdMeta,
          cookingMethodId.isAcceptableOrUnknown(
              data['cooking_method_id']!, _cookingMethodIdMeta));
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cookingMethodId};
  @override
  CookingMethodOil map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookingMethodOil(
      cookingMethodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cooking_method_id'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage'])!,
    );
  }

  @override
  $CookingMethodOilsTable createAlias(String alias) {
    return $CookingMethodOilsTable(attachedDatabase, alias);
  }
}

class CookingMethodOil extends DataClass
    implements Insertable<CookingMethodOil> {
  final int cookingMethodId;
  final double percentage;
  const CookingMethodOil(
      {required this.cookingMethodId, required this.percentage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cooking_method_id'] = Variable<int>(cookingMethodId);
    map['percentage'] = Variable<double>(percentage);
    return map;
  }

  CookingMethodOilsCompanion toCompanion(bool nullToAbsent) {
    return CookingMethodOilsCompanion(
      cookingMethodId: Value(cookingMethodId),
      percentage: Value(percentage),
    );
  }

  factory CookingMethodOil.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookingMethodOil(
      cookingMethodId: serializer.fromJson<int>(json['cookingMethodId']),
      percentage: serializer.fromJson<double>(json['percentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cookingMethodId': serializer.toJson<int>(cookingMethodId),
      'percentage': serializer.toJson<double>(percentage),
    };
  }

  CookingMethodOil copyWith({int? cookingMethodId, double? percentage}) =>
      CookingMethodOil(
        cookingMethodId: cookingMethodId ?? this.cookingMethodId,
        percentage: percentage ?? this.percentage,
      );
  CookingMethodOil copyWithCompanion(CookingMethodOilsCompanion data) {
    return CookingMethodOil(
      cookingMethodId: data.cookingMethodId.present
          ? data.cookingMethodId.value
          : this.cookingMethodId,
      percentage:
          data.percentage.present ? data.percentage.value : this.percentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookingMethodOil(')
          ..write('cookingMethodId: $cookingMethodId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cookingMethodId, percentage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookingMethodOil &&
          other.cookingMethodId == this.cookingMethodId &&
          other.percentage == this.percentage);
}

class CookingMethodOilsCompanion extends UpdateCompanion<CookingMethodOil> {
  final Value<int> cookingMethodId;
  final Value<double> percentage;
  const CookingMethodOilsCompanion({
    this.cookingMethodId = const Value.absent(),
    this.percentage = const Value.absent(),
  });
  CookingMethodOilsCompanion.insert({
    this.cookingMethodId = const Value.absent(),
    required double percentage,
  }) : percentage = Value(percentage);
  static Insertable<CookingMethodOil> custom({
    Expression<int>? cookingMethodId,
    Expression<double>? percentage,
  }) {
    return RawValuesInsertable({
      if (cookingMethodId != null) 'cooking_method_id': cookingMethodId,
      if (percentage != null) 'percentage': percentage,
    });
  }

  CookingMethodOilsCompanion copyWith(
      {Value<int>? cookingMethodId, Value<double>? percentage}) {
    return CookingMethodOilsCompanion(
      cookingMethodId: cookingMethodId ?? this.cookingMethodId,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cookingMethodId.present) {
      map['cooking_method_id'] = Variable<int>(cookingMethodId.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookingMethodOilsCompanion(')
          ..write('cookingMethodId: $cookingMethodId, ')
          ..write('percentage: $percentage')
          ..write(')'))
        .toString();
  }
}

class $SportMetsTable extends SportMets
    with TableInfo<$SportMetsTable, SportMet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SportMetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sportIdMeta =
      const VerificationMeta('sportId');
  @override
  late final GeneratedColumn<int> sportId = GeneratedColumn<int>(
      'sport_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameEsMeta = const VerificationMeta('nameEs');
  @override
  late final GeneratedColumn<String> nameEs = GeneratedColumn<String>(
      'name_es', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _metsMeta = const VerificationMeta('mets');
  @override
  late final GeneratedColumn<String> mets = GeneratedColumn<String>(
      'mets', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [sportId, nameEn, nameEs, mets];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sport_mets';
  @override
  VerificationContext validateIntegrity(Insertable<SportMet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sport_id')) {
      context.handle(_sportIdMeta,
          sportId.isAcceptableOrUnknown(data['sport_id']!, _sportIdMeta));
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    }
    if (data.containsKey('name_es')) {
      context.handle(_nameEsMeta,
          nameEs.isAcceptableOrUnknown(data['name_es']!, _nameEsMeta));
    }
    if (data.containsKey('mets')) {
      context.handle(
          _metsMeta, mets.isAcceptableOrUnknown(data['mets']!, _metsMeta));
    } else if (isInserting) {
      context.missing(_metsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sportId};
  @override
  SportMet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SportMet(
      sportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sport_id'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      nameEs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_es'])!,
      mets: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mets'])!,
    );
  }

  @override
  $SportMetsTable createAlias(String alias) {
    return $SportMetsTable(attachedDatabase, alias);
  }
}

class SportMet extends DataClass implements Insertable<SportMet> {
  final int sportId;
  final String nameEn;
  final String nameEs;
  final String mets;
  const SportMet(
      {required this.sportId,
      required this.nameEn,
      required this.nameEs,
      required this.mets});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sport_id'] = Variable<int>(sportId);
    map['name_en'] = Variable<String>(nameEn);
    map['name_es'] = Variable<String>(nameEs);
    map['mets'] = Variable<String>(mets);
    return map;
  }

  SportMetsCompanion toCompanion(bool nullToAbsent) {
    return SportMetsCompanion(
      sportId: Value(sportId),
      nameEn: Value(nameEn),
      nameEs: Value(nameEs),
      mets: Value(mets),
    );
  }

  factory SportMet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SportMet(
      sportId: serializer.fromJson<int>(json['sportId']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameEs: serializer.fromJson<String>(json['nameEs']),
      mets: serializer.fromJson<String>(json['mets']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sportId': serializer.toJson<int>(sportId),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameEs': serializer.toJson<String>(nameEs),
      'mets': serializer.toJson<String>(mets),
    };
  }

  SportMet copyWith(
          {int? sportId, String? nameEn, String? nameEs, String? mets}) =>
      SportMet(
        sportId: sportId ?? this.sportId,
        nameEn: nameEn ?? this.nameEn,
        nameEs: nameEs ?? this.nameEs,
        mets: mets ?? this.mets,
      );
  SportMet copyWithCompanion(SportMetsCompanion data) {
    return SportMet(
      sportId: data.sportId.present ? data.sportId.value : this.sportId,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameEs: data.nameEs.present ? data.nameEs.value : this.nameEs,
      mets: data.mets.present ? data.mets.value : this.mets,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SportMet(')
          ..write('sportId: $sportId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('mets: $mets')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sportId, nameEn, nameEs, mets);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SportMet &&
          other.sportId == this.sportId &&
          other.nameEn == this.nameEn &&
          other.nameEs == this.nameEs &&
          other.mets == this.mets);
}

class SportMetsCompanion extends UpdateCompanion<SportMet> {
  final Value<int> sportId;
  final Value<String> nameEn;
  final Value<String> nameEs;
  final Value<String> mets;
  const SportMetsCompanion({
    this.sportId = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.mets = const Value.absent(),
  });
  SportMetsCompanion.insert({
    this.sportId = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    required String mets,
  }) : mets = Value(mets);
  static Insertable<SportMet> custom({
    Expression<int>? sportId,
    Expression<String>? nameEn,
    Expression<String>? nameEs,
    Expression<String>? mets,
  }) {
    return RawValuesInsertable({
      if (sportId != null) 'sport_id': sportId,
      if (nameEn != null) 'name_en': nameEn,
      if (nameEs != null) 'name_es': nameEs,
      if (mets != null) 'mets': mets,
    });
  }

  SportMetsCompanion copyWith(
      {Value<int>? sportId,
      Value<String>? nameEn,
      Value<String>? nameEs,
      Value<String>? mets}) {
    return SportMetsCompanion(
      sportId: sportId ?? this.sportId,
      nameEn: nameEn ?? this.nameEn,
      nameEs: nameEs ?? this.nameEs,
      mets: mets ?? this.mets,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sportId.present) {
      map['sport_id'] = Variable<int>(sportId.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameEs.present) {
      map['name_es'] = Variable<String>(nameEs.value);
    }
    if (mets.present) {
      map['mets'] = Variable<String>(mets.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SportMetsCompanion(')
          ..write('sportId: $sportId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameEs: $nameEs, ')
          ..write('mets: $mets')
          ..write(')'))
        .toString();
  }
}

class $ReferenceDataVersionsTable extends ReferenceDataVersions
    with TableInfo<$ReferenceDataVersionsTable, ReferenceDataVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceDataVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_data_versions';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReferenceDataVersion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ReferenceDataVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceDataVersion(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $ReferenceDataVersionsTable createAlias(String alias) {
    return $ReferenceDataVersionsTable(attachedDatabase, alias);
  }
}

class ReferenceDataVersion extends DataClass
    implements Insertable<ReferenceDataVersion> {
  final String key;
  final int version;
  const ReferenceDataVersion({required this.key, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['version'] = Variable<int>(version);
    return map;
  }

  ReferenceDataVersionsCompanion toCompanion(bool nullToAbsent) {
    return ReferenceDataVersionsCompanion(
      key: Value(key),
      version: Value(version),
    );
  }

  factory ReferenceDataVersion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceDataVersion(
      key: serializer.fromJson<String>(json['key']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'version': serializer.toJson<int>(version),
    };
  }

  ReferenceDataVersion copyWith({String? key, int? version}) =>
      ReferenceDataVersion(
        key: key ?? this.key,
        version: version ?? this.version,
      );
  ReferenceDataVersion copyWithCompanion(ReferenceDataVersionsCompanion data) {
    return ReferenceDataVersion(
      key: data.key.present ? data.key.value : this.key,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataVersion(')
          ..write('key: $key, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceDataVersion &&
          other.key == this.key &&
          other.version == this.version);
}

class ReferenceDataVersionsCompanion
    extends UpdateCompanion<ReferenceDataVersion> {
  final Value<String> key;
  final Value<int> version;
  final Value<int> rowid;
  const ReferenceDataVersionsCompanion({
    this.key = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceDataVersionsCompanion.insert({
    required String key,
    required int version,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        version = Value(version);
  static Insertable<ReferenceDataVersion> custom({
    Expression<String>? key,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceDataVersionsCompanion copyWith(
      {Value<String>? key, Value<int>? version, Value<int>? rowid}) {
    return ReferenceDataVersionsCompanion(
      key: key ?? this.key,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataVersionsCompanion(')
          ..write('key: $key, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferenceDataBlobsTable extends ReferenceDataBlobs
    with TableInfo<$ReferenceDataBlobsTable, ReferenceDataBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceDataBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_data_blobs';
  @override
  VerificationContext validateIntegrity(Insertable<ReferenceDataBlob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ReferenceDataBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceDataBlob(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $ReferenceDataBlobsTable createAlias(String alias) {
    return $ReferenceDataBlobsTable(attachedDatabase, alias);
  }
}

class ReferenceDataBlob extends DataClass
    implements Insertable<ReferenceDataBlob> {
  final String key;
  final String data;
  const ReferenceDataBlob({required this.key, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['data'] = Variable<String>(data);
    return map;
  }

  ReferenceDataBlobsCompanion toCompanion(bool nullToAbsent) {
    return ReferenceDataBlobsCompanion(
      key: Value(key),
      data: Value(data),
    );
  }

  factory ReferenceDataBlob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceDataBlob(
      key: serializer.fromJson<String>(json['key']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'data': serializer.toJson<String>(data),
    };
  }

  ReferenceDataBlob copyWith({String? key, String? data}) => ReferenceDataBlob(
        key: key ?? this.key,
        data: data ?? this.data,
      );
  ReferenceDataBlob copyWithCompanion(ReferenceDataBlobsCompanion data) {
    return ReferenceDataBlob(
      key: data.key.present ? data.key.value : this.key,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataBlob(')
          ..write('key: $key, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceDataBlob &&
          other.key == this.key &&
          other.data == this.data);
}

class ReferenceDataBlobsCompanion extends UpdateCompanion<ReferenceDataBlob> {
  final Value<String> key;
  final Value<String> data;
  final Value<int> rowid;
  const ReferenceDataBlobsCompanion({
    this.key = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceDataBlobsCompanion.insert({
    required String key,
    required String data,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        data = Value(data);
  static Insertable<ReferenceDataBlob> custom({
    Expression<String>? key,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceDataBlobsCompanion copyWith(
      {Value<String>? key, Value<String>? data, Value<int>? rowid}) {
    return ReferenceDataBlobsCompanion(
      key: key ?? this.key,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataBlobsCompanion(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ReferenceDatabase extends GeneratedDatabase {
  _$ReferenceDatabase(QueryExecutor e) : super(e);
  $ReferenceDatabaseManager get managers => $ReferenceDatabaseManager(this);
  late final $NutrientCompositionsTable nutrientCompositions =
      $NutrientCompositionsTable(this);
  late final $NutrientLossesTable nutrientLosses = $NutrientLossesTable(this);
  late final $CookingMethodOilsTable cookingMethodOils =
      $CookingMethodOilsTable(this);
  late final $SportMetsTable sportMets = $SportMetsTable(this);
  late final $ReferenceDataVersionsTable referenceDataVersions =
      $ReferenceDataVersionsTable(this);
  late final $ReferenceDataBlobsTable referenceDataBlobs =
      $ReferenceDataBlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        nutrientCompositions,
        nutrientLosses,
        cookingMethodOils,
        sportMets,
        referenceDataVersions,
        referenceDataBlobs
      ];
}

typedef $$NutrientCompositionsTableCreateCompanionBuilder
    = NutrientCompositionsCompanion Function({
  Value<int> foodId,
  required int isFood,
  Value<String> group,
  Value<String> nameEn,
  Value<String> nameEs,
  Value<int> recommendable,
  Value<String?> freeSugar,
  required String params,
  Value<int> recGroup,
  Value<double> exchangePortion,
  Value<String> allergiesExclusions,
  Value<String> intolerances,
  Value<String> diseases,
  Value<int> guts,
  Value<int> rarity,
  Value<int> novaClassification,
  Value<int> included,
});
typedef $$NutrientCompositionsTableUpdateCompanionBuilder
    = NutrientCompositionsCompanion Function({
  Value<int> foodId,
  Value<int> isFood,
  Value<String> group,
  Value<String> nameEn,
  Value<String> nameEs,
  Value<int> recommendable,
  Value<String?> freeSugar,
  Value<String> params,
  Value<int> recGroup,
  Value<double> exchangePortion,
  Value<String> allergiesExclusions,
  Value<String> intolerances,
  Value<String> diseases,
  Value<int> guts,
  Value<int> rarity,
  Value<int> novaClassification,
  Value<int> included,
});

class $$NutrientCompositionsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $NutrientCompositionsTable> {
  $$NutrientCompositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isFood => $composableBuilder(
      column: $table.isFood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEs => $composableBuilder(
      column: $table.nameEs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recommendable => $composableBuilder(
      column: $table.recommendable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get freeSugar => $composableBuilder(
      column: $table.freeSugar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get params => $composableBuilder(
      column: $table.params, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recGroup => $composableBuilder(
      column: $table.recGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangePortion => $composableBuilder(
      column: $table.exchangePortion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergiesExclusions => $composableBuilder(
      column: $table.allergiesExclusions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intolerances => $composableBuilder(
      column: $table.intolerances, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diseases => $composableBuilder(
      column: $table.diseases, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get guts => $composableBuilder(
      column: $table.guts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get novaClassification => $composableBuilder(
      column: $table.novaClassification,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get included => $composableBuilder(
      column: $table.included, builder: (column) => ColumnFilters(column));
}

class $$NutrientCompositionsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $NutrientCompositionsTable> {
  $$NutrientCompositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isFood => $composableBuilder(
      column: $table.isFood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEs => $composableBuilder(
      column: $table.nameEs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recommendable => $composableBuilder(
      column: $table.recommendable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get freeSugar => $composableBuilder(
      column: $table.freeSugar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get params => $composableBuilder(
      column: $table.params, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recGroup => $composableBuilder(
      column: $table.recGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangePortion => $composableBuilder(
      column: $table.exchangePortion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergiesExclusions => $composableBuilder(
      column: $table.allergiesExclusions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intolerances => $composableBuilder(
      column: $table.intolerances,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diseases => $composableBuilder(
      column: $table.diseases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get guts => $composableBuilder(
      column: $table.guts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get novaClassification => $composableBuilder(
      column: $table.novaClassification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get included => $composableBuilder(
      column: $table.included, builder: (column) => ColumnOrderings(column));
}

class $$NutrientCompositionsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $NutrientCompositionsTable> {
  $$NutrientCompositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<int> get isFood =>
      $composableBuilder(column: $table.isFood, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<int> get recommendable => $composableBuilder(
      column: $table.recommendable, builder: (column) => column);

  GeneratedColumn<String> get freeSugar =>
      $composableBuilder(column: $table.freeSugar, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<int> get recGroup =>
      $composableBuilder(column: $table.recGroup, builder: (column) => column);

  GeneratedColumn<double> get exchangePortion => $composableBuilder(
      column: $table.exchangePortion, builder: (column) => column);

  GeneratedColumn<String> get allergiesExclusions => $composableBuilder(
      column: $table.allergiesExclusions, builder: (column) => column);

  GeneratedColumn<String> get intolerances => $composableBuilder(
      column: $table.intolerances, builder: (column) => column);

  GeneratedColumn<String> get diseases =>
      $composableBuilder(column: $table.diseases, builder: (column) => column);

  GeneratedColumn<int> get guts =>
      $composableBuilder(column: $table.guts, builder: (column) => column);

  GeneratedColumn<int> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<int> get novaClassification => $composableBuilder(
      column: $table.novaClassification, builder: (column) => column);

  GeneratedColumn<int> get included =>
      $composableBuilder(column: $table.included, builder: (column) => column);
}

class $$NutrientCompositionsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $NutrientCompositionsTable,
    NutrientComposition,
    $$NutrientCompositionsTableFilterComposer,
    $$NutrientCompositionsTableOrderingComposer,
    $$NutrientCompositionsTableAnnotationComposer,
    $$NutrientCompositionsTableCreateCompanionBuilder,
    $$NutrientCompositionsTableUpdateCompanionBuilder,
    (
      NutrientComposition,
      BaseReferences<_$ReferenceDatabase, $NutrientCompositionsTable,
          NutrientComposition>
    ),
    NutrientComposition,
    PrefetchHooks Function()> {
  $$NutrientCompositionsTableTableManager(
      _$ReferenceDatabase db, $NutrientCompositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutrientCompositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutrientCompositionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutrientCompositionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            Value<int> isFood = const Value.absent(),
            Value<String> group = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameEs = const Value.absent(),
            Value<int> recommendable = const Value.absent(),
            Value<String?> freeSugar = const Value.absent(),
            Value<String> params = const Value.absent(),
            Value<int> recGroup = const Value.absent(),
            Value<double> exchangePortion = const Value.absent(),
            Value<String> allergiesExclusions = const Value.absent(),
            Value<String> intolerances = const Value.absent(),
            Value<String> diseases = const Value.absent(),
            Value<int> guts = const Value.absent(),
            Value<int> rarity = const Value.absent(),
            Value<int> novaClassification = const Value.absent(),
            Value<int> included = const Value.absent(),
          }) =>
              NutrientCompositionsCompanion(
            foodId: foodId,
            isFood: isFood,
            group: group,
            nameEn: nameEn,
            nameEs: nameEs,
            recommendable: recommendable,
            freeSugar: freeSugar,
            params: params,
            recGroup: recGroup,
            exchangePortion: exchangePortion,
            allergiesExclusions: allergiesExclusions,
            intolerances: intolerances,
            diseases: diseases,
            guts: guts,
            rarity: rarity,
            novaClassification: novaClassification,
            included: included,
          ),
          createCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            required int isFood,
            Value<String> group = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameEs = const Value.absent(),
            Value<int> recommendable = const Value.absent(),
            Value<String?> freeSugar = const Value.absent(),
            required String params,
            Value<int> recGroup = const Value.absent(),
            Value<double> exchangePortion = const Value.absent(),
            Value<String> allergiesExclusions = const Value.absent(),
            Value<String> intolerances = const Value.absent(),
            Value<String> diseases = const Value.absent(),
            Value<int> guts = const Value.absent(),
            Value<int> rarity = const Value.absent(),
            Value<int> novaClassification = const Value.absent(),
            Value<int> included = const Value.absent(),
          }) =>
              NutrientCompositionsCompanion.insert(
            foodId: foodId,
            isFood: isFood,
            group: group,
            nameEn: nameEn,
            nameEs: nameEs,
            recommendable: recommendable,
            freeSugar: freeSugar,
            params: params,
            recGroup: recGroup,
            exchangePortion: exchangePortion,
            allergiesExclusions: allergiesExclusions,
            intolerances: intolerances,
            diseases: diseases,
            guts: guts,
            rarity: rarity,
            novaClassification: novaClassification,
            included: included,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NutrientCompositionsTableProcessedTableManager
    = ProcessedTableManager<
        _$ReferenceDatabase,
        $NutrientCompositionsTable,
        NutrientComposition,
        $$NutrientCompositionsTableFilterComposer,
        $$NutrientCompositionsTableOrderingComposer,
        $$NutrientCompositionsTableAnnotationComposer,
        $$NutrientCompositionsTableCreateCompanionBuilder,
        $$NutrientCompositionsTableUpdateCompanionBuilder,
        (
          NutrientComposition,
          BaseReferences<_$ReferenceDatabase, $NutrientCompositionsTable,
              NutrientComposition>
        ),
        NutrientComposition,
        PrefetchHooks Function()>;
typedef $$NutrientLossesTableCreateCompanionBuilder = NutrientLossesCompanion
    Function({
  Value<int> cookingMethodId,
  required String losses,
});
typedef $$NutrientLossesTableUpdateCompanionBuilder = NutrientLossesCompanion
    Function({
  Value<int> cookingMethodId,
  Value<String> losses,
});

class $$NutrientLossesTableFilterComposer
    extends Composer<_$ReferenceDatabase, $NutrientLossesTable> {
  $$NutrientLossesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnFilters(column));
}

class $$NutrientLossesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $NutrientLossesTable> {
  $$NutrientLossesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get losses => $composableBuilder(
      column: $table.losses, builder: (column) => ColumnOrderings(column));
}

class $$NutrientLossesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $NutrientLossesTable> {
  $$NutrientLossesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId, builder: (column) => column);

  GeneratedColumn<String> get losses =>
      $composableBuilder(column: $table.losses, builder: (column) => column);
}

class $$NutrientLossesTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $NutrientLossesTable,
    NutrientLossEntry,
    $$NutrientLossesTableFilterComposer,
    $$NutrientLossesTableOrderingComposer,
    $$NutrientLossesTableAnnotationComposer,
    $$NutrientLossesTableCreateCompanionBuilder,
    $$NutrientLossesTableUpdateCompanionBuilder,
    (
      NutrientLossEntry,
      BaseReferences<_$ReferenceDatabase, $NutrientLossesTable,
          NutrientLossEntry>
    ),
    NutrientLossEntry,
    PrefetchHooks Function()> {
  $$NutrientLossesTableTableManager(
      _$ReferenceDatabase db, $NutrientLossesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutrientLossesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutrientLossesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutrientLossesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> cookingMethodId = const Value.absent(),
            Value<String> losses = const Value.absent(),
          }) =>
              NutrientLossesCompanion(
            cookingMethodId: cookingMethodId,
            losses: losses,
          ),
          createCompanionCallback: ({
            Value<int> cookingMethodId = const Value.absent(),
            required String losses,
          }) =>
              NutrientLossesCompanion.insert(
            cookingMethodId: cookingMethodId,
            losses: losses,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NutrientLossesTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $NutrientLossesTable,
    NutrientLossEntry,
    $$NutrientLossesTableFilterComposer,
    $$NutrientLossesTableOrderingComposer,
    $$NutrientLossesTableAnnotationComposer,
    $$NutrientLossesTableCreateCompanionBuilder,
    $$NutrientLossesTableUpdateCompanionBuilder,
    (
      NutrientLossEntry,
      BaseReferences<_$ReferenceDatabase, $NutrientLossesTable,
          NutrientLossEntry>
    ),
    NutrientLossEntry,
    PrefetchHooks Function()>;
typedef $$CookingMethodOilsTableCreateCompanionBuilder
    = CookingMethodOilsCompanion Function({
  Value<int> cookingMethodId,
  required double percentage,
});
typedef $$CookingMethodOilsTableUpdateCompanionBuilder
    = CookingMethodOilsCompanion Function({
  Value<int> cookingMethodId,
  Value<double> percentage,
});

class $$CookingMethodOilsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $CookingMethodOilsTable> {
  $$CookingMethodOilsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnFilters(column));
}

class $$CookingMethodOilsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $CookingMethodOilsTable> {
  $$CookingMethodOilsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnOrderings(column));
}

class $$CookingMethodOilsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $CookingMethodOilsTable> {
  $$CookingMethodOilsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cookingMethodId => $composableBuilder(
      column: $table.cookingMethodId, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => column);
}

class $$CookingMethodOilsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $CookingMethodOilsTable,
    CookingMethodOil,
    $$CookingMethodOilsTableFilterComposer,
    $$CookingMethodOilsTableOrderingComposer,
    $$CookingMethodOilsTableAnnotationComposer,
    $$CookingMethodOilsTableCreateCompanionBuilder,
    $$CookingMethodOilsTableUpdateCompanionBuilder,
    (
      CookingMethodOil,
      BaseReferences<_$ReferenceDatabase, $CookingMethodOilsTable,
          CookingMethodOil>
    ),
    CookingMethodOil,
    PrefetchHooks Function()> {
  $$CookingMethodOilsTableTableManager(
      _$ReferenceDatabase db, $CookingMethodOilsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookingMethodOilsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookingMethodOilsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CookingMethodOilsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> cookingMethodId = const Value.absent(),
            Value<double> percentage = const Value.absent(),
          }) =>
              CookingMethodOilsCompanion(
            cookingMethodId: cookingMethodId,
            percentage: percentage,
          ),
          createCompanionCallback: ({
            Value<int> cookingMethodId = const Value.absent(),
            required double percentage,
          }) =>
              CookingMethodOilsCompanion.insert(
            cookingMethodId: cookingMethodId,
            percentage: percentage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CookingMethodOilsTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $CookingMethodOilsTable,
    CookingMethodOil,
    $$CookingMethodOilsTableFilterComposer,
    $$CookingMethodOilsTableOrderingComposer,
    $$CookingMethodOilsTableAnnotationComposer,
    $$CookingMethodOilsTableCreateCompanionBuilder,
    $$CookingMethodOilsTableUpdateCompanionBuilder,
    (
      CookingMethodOil,
      BaseReferences<_$ReferenceDatabase, $CookingMethodOilsTable,
          CookingMethodOil>
    ),
    CookingMethodOil,
    PrefetchHooks Function()>;
typedef $$SportMetsTableCreateCompanionBuilder = SportMetsCompanion Function({
  Value<int> sportId,
  Value<String> nameEn,
  Value<String> nameEs,
  required String mets,
});
typedef $$SportMetsTableUpdateCompanionBuilder = SportMetsCompanion Function({
  Value<int> sportId,
  Value<String> nameEn,
  Value<String> nameEs,
  Value<String> mets,
});

class $$SportMetsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $SportMetsTable> {
  $$SportMetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sportId => $composableBuilder(
      column: $table.sportId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEs => $composableBuilder(
      column: $table.nameEs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mets => $composableBuilder(
      column: $table.mets, builder: (column) => ColumnFilters(column));
}

class $$SportMetsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $SportMetsTable> {
  $$SportMetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sportId => $composableBuilder(
      column: $table.sportId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEs => $composableBuilder(
      column: $table.nameEs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mets => $composableBuilder(
      column: $table.mets, builder: (column) => ColumnOrderings(column));
}

class $$SportMetsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $SportMetsTable> {
  $$SportMetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sportId =>
      $composableBuilder(column: $table.sportId, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameEs =>
      $composableBuilder(column: $table.nameEs, builder: (column) => column);

  GeneratedColumn<String> get mets =>
      $composableBuilder(column: $table.mets, builder: (column) => column);
}

class $$SportMetsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $SportMetsTable,
    SportMet,
    $$SportMetsTableFilterComposer,
    $$SportMetsTableOrderingComposer,
    $$SportMetsTableAnnotationComposer,
    $$SportMetsTableCreateCompanionBuilder,
    $$SportMetsTableUpdateCompanionBuilder,
    (SportMet, BaseReferences<_$ReferenceDatabase, $SportMetsTable, SportMet>),
    SportMet,
    PrefetchHooks Function()> {
  $$SportMetsTableTableManager(_$ReferenceDatabase db, $SportMetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SportMetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SportMetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SportMetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> sportId = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameEs = const Value.absent(),
            Value<String> mets = const Value.absent(),
          }) =>
              SportMetsCompanion(
            sportId: sportId,
            nameEn: nameEn,
            nameEs: nameEs,
            mets: mets,
          ),
          createCompanionCallback: ({
            Value<int> sportId = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameEs = const Value.absent(),
            required String mets,
          }) =>
              SportMetsCompanion.insert(
            sportId: sportId,
            nameEn: nameEn,
            nameEs: nameEs,
            mets: mets,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SportMetsTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $SportMetsTable,
    SportMet,
    $$SportMetsTableFilterComposer,
    $$SportMetsTableOrderingComposer,
    $$SportMetsTableAnnotationComposer,
    $$SportMetsTableCreateCompanionBuilder,
    $$SportMetsTableUpdateCompanionBuilder,
    (SportMet, BaseReferences<_$ReferenceDatabase, $SportMetsTable, SportMet>),
    SportMet,
    PrefetchHooks Function()>;
typedef $$ReferenceDataVersionsTableCreateCompanionBuilder
    = ReferenceDataVersionsCompanion Function({
  required String key,
  required int version,
  Value<int> rowid,
});
typedef $$ReferenceDataVersionsTableUpdateCompanionBuilder
    = ReferenceDataVersionsCompanion Function({
  Value<String> key,
  Value<int> version,
  Value<int> rowid,
});

class $$ReferenceDataVersionsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataVersionsTable> {
  $$ReferenceDataVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$ReferenceDataVersionsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataVersionsTable> {
  $$ReferenceDataVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$ReferenceDataVersionsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataVersionsTable> {
  $$ReferenceDataVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$ReferenceDataVersionsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $ReferenceDataVersionsTable,
    ReferenceDataVersion,
    $$ReferenceDataVersionsTableFilterComposer,
    $$ReferenceDataVersionsTableOrderingComposer,
    $$ReferenceDataVersionsTableAnnotationComposer,
    $$ReferenceDataVersionsTableCreateCompanionBuilder,
    $$ReferenceDataVersionsTableUpdateCompanionBuilder,
    (
      ReferenceDataVersion,
      BaseReferences<_$ReferenceDatabase, $ReferenceDataVersionsTable,
          ReferenceDataVersion>
    ),
    ReferenceDataVersion,
    PrefetchHooks Function()> {
  $$ReferenceDataVersionsTableTableManager(
      _$ReferenceDatabase db, $ReferenceDataVersionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceDataVersionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceDataVersionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceDataVersionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceDataVersionsCompanion(
            key: key,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required int version,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceDataVersionsCompanion.insert(
            key: key,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferenceDataVersionsTableProcessedTableManager
    = ProcessedTableManager<
        _$ReferenceDatabase,
        $ReferenceDataVersionsTable,
        ReferenceDataVersion,
        $$ReferenceDataVersionsTableFilterComposer,
        $$ReferenceDataVersionsTableOrderingComposer,
        $$ReferenceDataVersionsTableAnnotationComposer,
        $$ReferenceDataVersionsTableCreateCompanionBuilder,
        $$ReferenceDataVersionsTableUpdateCompanionBuilder,
        (
          ReferenceDataVersion,
          BaseReferences<_$ReferenceDatabase, $ReferenceDataVersionsTable,
              ReferenceDataVersion>
        ),
        ReferenceDataVersion,
        PrefetchHooks Function()>;
typedef $$ReferenceDataBlobsTableCreateCompanionBuilder
    = ReferenceDataBlobsCompanion Function({
  required String key,
  required String data,
  Value<int> rowid,
});
typedef $$ReferenceDataBlobsTableUpdateCompanionBuilder
    = ReferenceDataBlobsCompanion Function({
  Value<String> key,
  Value<String> data,
  Value<int> rowid,
});

class $$ReferenceDataBlobsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataBlobsTable> {
  $$ReferenceDataBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));
}

class $$ReferenceDataBlobsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataBlobsTable> {
  $$ReferenceDataBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));
}

class $$ReferenceDataBlobsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ReferenceDataBlobsTable> {
  $$ReferenceDataBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$ReferenceDataBlobsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $ReferenceDataBlobsTable,
    ReferenceDataBlob,
    $$ReferenceDataBlobsTableFilterComposer,
    $$ReferenceDataBlobsTableOrderingComposer,
    $$ReferenceDataBlobsTableAnnotationComposer,
    $$ReferenceDataBlobsTableCreateCompanionBuilder,
    $$ReferenceDataBlobsTableUpdateCompanionBuilder,
    (
      ReferenceDataBlob,
      BaseReferences<_$ReferenceDatabase, $ReferenceDataBlobsTable,
          ReferenceDataBlob>
    ),
    ReferenceDataBlob,
    PrefetchHooks Function()> {
  $$ReferenceDataBlobsTableTableManager(
      _$ReferenceDatabase db, $ReferenceDataBlobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceDataBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceDataBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceDataBlobsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceDataBlobsCompanion(
            key: key,
            data: data,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String data,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferenceDataBlobsCompanion.insert(
            key: key,
            data: data,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReferenceDataBlobsTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $ReferenceDataBlobsTable,
    ReferenceDataBlob,
    $$ReferenceDataBlobsTableFilterComposer,
    $$ReferenceDataBlobsTableOrderingComposer,
    $$ReferenceDataBlobsTableAnnotationComposer,
    $$ReferenceDataBlobsTableCreateCompanionBuilder,
    $$ReferenceDataBlobsTableUpdateCompanionBuilder,
    (
      ReferenceDataBlob,
      BaseReferences<_$ReferenceDatabase, $ReferenceDataBlobsTable,
          ReferenceDataBlob>
    ),
    ReferenceDataBlob,
    PrefetchHooks Function()>;

class $ReferenceDatabaseManager {
  final _$ReferenceDatabase _db;
  $ReferenceDatabaseManager(this._db);
  $$NutrientCompositionsTableTableManager get nutrientCompositions =>
      $$NutrientCompositionsTableTableManager(_db, _db.nutrientCompositions);
  $$NutrientLossesTableTableManager get nutrientLosses =>
      $$NutrientLossesTableTableManager(_db, _db.nutrientLosses);
  $$CookingMethodOilsTableTableManager get cookingMethodOils =>
      $$CookingMethodOilsTableTableManager(_db, _db.cookingMethodOils);
  $$SportMetsTableTableManager get sportMets =>
      $$SportMetsTableTableManager(_db, _db.sportMets);
  $$ReferenceDataVersionsTableTableManager get referenceDataVersions =>
      $$ReferenceDataVersionsTableTableManager(_db, _db.referenceDataVersions);
  $$ReferenceDataBlobsTableTableManager get referenceDataBlobs =>
      $$ReferenceDataBlobsTableTableManager(_db, _db.referenceDataBlobs);
}
