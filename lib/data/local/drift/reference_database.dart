import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'reference_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

/// Per-food/drink nutrient composition (~1800 rows).
/// `params` is stored as a JSON-encoded Map<String, double>.
class NutrientCompositions extends Table {
  IntColumn get foodId => integer()();
  IntColumn get isFood => integer()(); // S3 convention: 1 = drink, 0 = food
  TextColumn get group => text().withDefault(const Constant(''))();
  TextColumn get nameEn => text().withDefault(const Constant(''))();
  TextColumn get nameEs => text().withDefault(const Constant(''))();
  IntColumn get recommendable => integer().withDefault(const Constant(0))();
  TextColumn get freeSugar => text().nullable()();
  TextColumn get params => text()(); // JSON Map<String, double>

  @override
  Set<Column> get primaryKey => {foodId};
}

/// Per-cooking-method nutrient retention loss factors.
/// `losses` is a JSON-encoded Map<String, double> where keys are nutrient
/// names and values are the fractional loss (0.0-1.0).
@DataClassName('NutrientLossEntry')
class NutrientLosses extends Table {
  IntColumn get cookingMethodId => integer()();
  TextColumn get losses => text()(); // JSON Map<String, double>

  @override
  Set<Column> get primaryKey => {cookingMethodId};
}

/// Oil absorption percentage per cooking method.
class CookingMethodOils extends Table {
  IntColumn get cookingMethodId => integer()();
  RealColumn get percentage => real()();

  @override
  Set<Column> get primaryKey => {cookingMethodId};
}

/// Full METs array per sport (one value per intensity level).
class SportMets extends Table {
  IntColumn get sportId => integer()();
  TextColumn get nameEn => text().withDefault(const Constant(''))();
  TextColumn get nameEs => text().withDefault(const Constant(''))();
  TextColumn get mets => text()(); // JSON List<double>

  @override
  Set<Column> get primaryKey => {sportId};
}

/// Tracks the version of each reference data set so we only re-download
/// when the server has a newer version.
class ReferenceDataVersions extends Table {
  TextColumn get key => text()(); // e.g. 'nutrients', 'nutrientLoss', 'cookingOils', 'sportMets'
  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  NutrientCompositions,
  NutrientLosses,
  CookingMethodOils,
  SportMets,
  ReferenceDataVersions,
])
class ReferenceDatabase extends _$ReferenceDatabase {
  ReferenceDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // -- Nutrient Compositions ------------------------------------------------

  Future<NutrientComposition?> getNutrientComposition(int foodId) {
    return (select(nutrientCompositions)
          ..where((t) => t.foodId.equals(foodId)))
        .getSingleOrNull();
  }

  Future<List<NutrientComposition>> getAllNutrientCompositions() {
    return select(nutrientCompositions).get();
  }

  Future<void> upsertNutrientComposition(NutrientCompositionsCompanion entry) {
    return into(nutrientCompositions).insertOnConflictUpdate(entry);
  }

  Future<void> replaceAllNutrientCompositions(
      List<NutrientCompositionsCompanion> entries) {
    return transaction(() async {
      await delete(nutrientCompositions).go();
      await batch((b) {
        b.insertAll(nutrientCompositions, entries);
      });
    });
  }

  // -- Nutrient Losses ------------------------------------------------------

  Future<NutrientLossEntry?> getNutrientLoss(int cookingMethodId) {
    return (select(nutrientLosses)
          ..where((t) => t.cookingMethodId.equals(cookingMethodId)))
        .getSingleOrNull();
  }

  Future<void> replaceAllNutrientLosses(
      List<NutrientLossesCompanion> entries) {
    return transaction(() async {
      await delete(nutrientLosses).go();
      await batch((b) {
        b.insertAll(nutrientLosses, entries);
      });
    });
  }

  // -- Cooking Method Oils --------------------------------------------------

  Future<CookingMethodOil?> getCookingMethodOil(int cookingMethodId) {
    return (select(cookingMethodOils)
          ..where((t) => t.cookingMethodId.equals(cookingMethodId)))
        .getSingleOrNull();
  }

  Future<void> replaceAllCookingMethodOils(
      List<CookingMethodOilsCompanion> entries) {
    return transaction(() async {
      await delete(cookingMethodOils).go();
      await batch((b) {
        b.insertAll(cookingMethodOils, entries);
      });
    });
  }

  // -- Sport METs -----------------------------------------------------------

  Future<SportMet?> getSportMets(int sportId) {
    return (select(sportMets)..where((t) => t.sportId.equals(sportId)))
        .getSingleOrNull();
  }

  Future<List<SportMet>> getAllSportMets() {
    return select(sportMets).get();
  }

  Future<void> replaceAllSportMets(List<SportMetsCompanion> entries) {
    return transaction(() async {
      await delete(sportMets).go();
      await batch((b) {
        b.insertAll(sportMets, entries);
      });
    });
  }

  // -- Version tracking -----------------------------------------------------

  Future<int> getReferenceVersion(String key) async {
    final row = await (select(referenceDataVersions)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.version ?? -1;
  }

  Future<void> setReferenceVersion(String key, int version) {
    return into(referenceDataVersions).insertOnConflictUpdate(
      ReferenceDataVersionsCompanion(
        key: Value(key),
        version: Value(version),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: open database
// ---------------------------------------------------------------------------

/// Opens (or creates) the reference SQLite database in the app's documents
/// directory. Call once at app startup.
Future<ReferenceDatabase> openReferenceDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'reference_data.sqlite'));
  return ReferenceDatabase(NativeDatabase(file));
}
