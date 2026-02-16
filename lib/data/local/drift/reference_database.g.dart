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
  @override
  List<GeneratedColumn> get $columns =>
      [foodId, isFood, group, nameEn, nameEs, recommendable, freeSugar, params];
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
  const NutrientComposition(
      {required this.foodId,
      required this.isFood,
      required this.group,
      required this.nameEn,
      required this.nameEs,
      required this.recommendable,
      this.freeSugar,
      required this.params});
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
          String? params}) =>
      NutrientComposition(
        foodId: foodId ?? this.foodId,
        isFood: isFood ?? this.isFood,
        group: group ?? this.group,
        nameEn: nameEn ?? this.nameEn,
        nameEs: nameEs ?? this.nameEs,
        recommendable: recommendable ?? this.recommendable,
        freeSugar: freeSugar.present ? freeSugar.value : this.freeSugar,
        params: params ?? this.params,
      );
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
          ..write('params: $params')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      foodId, isFood, group, nameEn, nameEs, recommendable, freeSugar, params);
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
          other.params == this.params);
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
  const NutrientCompositionsCompanion({
    this.foodId = const Value.absent(),
    this.isFood = const Value.absent(),
    this.group = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameEs = const Value.absent(),
    this.recommendable = const Value.absent(),
    this.freeSugar = const Value.absent(),
    this.params = const Value.absent(),
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
      Value<String>? params}) {
    return NutrientCompositionsCompanion(
      foodId: foodId ?? this.foodId,
      isFood: isFood ?? this.isFood,
      group: group ?? this.group,
      nameEn: nameEn ?? this.nameEn,
      nameEs: nameEs ?? this.nameEs,
      recommendable: recommendable ?? this.recommendable,
      freeSugar: freeSugar ?? this.freeSugar,
      params: params ?? this.params,
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
          ..write('params: $params')
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
