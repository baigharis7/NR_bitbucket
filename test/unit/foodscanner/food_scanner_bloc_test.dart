import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/food_fuzzy_matcher.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_state.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeBarcodeProvider implements BarcodeNutritionProvider {
  BarcodeProduct? nextResult;
  String? lastBarcode;

  @override
  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    lastBarcode = barcode;
    return nextResult;
  }
}

class FakeScannedFoodRepository implements ScannedFoodRepository {
  ScannedFoodEntity? cachedEntity;
  ScannedFoodEntity? lastSaved;
  int nextId = -1;

  @override
  Future<ScannedFoodEntity?> findByLookupKey(String lookupKey) async =>
      cachedEntity;

  @override
  Future<void> saveScannedFood(ScannedFoodEntity entity) async {
    lastSaved = entity;
  }

  @override
  Future<int> nextLocalFoodId() async => nextId;
}

class FakeVisualProvider implements VisualFoodProvider {
  List<VisualFoodResult> nextResults = [];
  Exception? throwOnCall;

  @override
  Future<List<VisualFoodResult>> identifyFoods(dynamic imageBytes) async {
    if (throwOnCall != null) throw throwOnCall!;
    return nextResults;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

FoodItemMaster _food(int id, String en, {String? group}) =>
    FoodItemMaster(id: id, en: en, es: en, group: group ?? 'food');

FoodScannerBloc _buildBloc({
  FakeBarcodeProvider? barcodeProvider,
  FakeScannedFoodRepository? repo,
  FakeVisualProvider? visualProvider,
  List<FoodItemMaster>? masterFoods,
}) {
  final bloc = FoodScannerBloc(
    barcodeProvider: barcodeProvider ?? FakeBarcodeProvider(),
    scannedFoodRepository: repo ?? FakeScannedFoodRepository(),
    visualFoodProvider: visualProvider,
  );
  if (masterFoods != null) {
    bloc.initializeMatcher(masterFoods);
  }
  return bloc;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FoodScannerBloc', () {
    // -----------------------------------------------------------------------
    // CapturePhotoAction
    // -----------------------------------------------------------------------

    group('CapturePhotoAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits error when visualFoodProvider is null',
        build: () => _buildBloc(),
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        expect: () => [
          isA<FoodScannerState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            'Visual recognition not configured',
          ),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits error when no food detected',
        build: () {
          final vp = FakeVisualProvider()..nextResults = [];
          return _buildBloc(visualProvider: vp);
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        expect: () => [
          // isProcessing = true
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // isProcessing = false, error
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'No food detected in the image'),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits results on successful visual detection',
        build: () {
          final vp = FakeVisualProvider()
            ..nextResults = [
              VisualFoodResult(
                  name: 'Banana', estimatedGrams: 120, estimatedKcal: 89),
            ];
          return _buildBloc(
            visualProvider: vp,
            masterFoods: [_food(1, 'Banana')],
          );
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        // CapturePhotoAction emits isProcessing=true, then dispatches
        // OnVisualFoodDetectedAction internally, which emits results.
        expect: () => [
          // 1st: isProcessing = true
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // 2nd: OnVisualFoodDetected emits isProcessing=true again (re-entry)
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // 3rd: results with matched food
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.results.length, 'results.length', 1)
              .having(
                  (s) => s.results.first.scanResult.scannedName, 'name', 'Banana')
              .having(
                  (s) => s.results.first.scanResult.matchedFoodId, 'matchedId', 1),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'handles generic exception gracefully',
        build: () {
          final vp = FakeVisualProvider()
            ..throwOnCall = Exception('Network timeout');
          return _buildBloc(visualProvider: vp);
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        expect: () => [
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('Network timeout')),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // OnVisualFoodDetectedAction
    // -----------------------------------------------------------------------

    group('OnVisualFoodDetectedAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'creates results with matched food IDs',
        build: () => _buildBloc(
          masterFoods: [
            _food(10, 'Scrambled eggs'),
            _food(20, 'White rice'),
          ],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
              name: 'Scrambled eggs', estimatedGrams: 150),
          DetectedFoodCandidate(name: 'White rice', estimatedGrams: 200),
        ])),
        expect: () => [
          // isProcessing = true
          isA<FoodScannerState>(),
          // results emitted
          isA<FoodScannerState>()
              .having((s) => s.results.length, 'results.length', 2)
              .having((s) => s.results[0].scanResult.matchedFoodId, 'id0', 10)
              .having((s) => s.results[1].scanResult.matchedFoodId, 'id1', 20)
              .having((s) => s.results[0].scanResult.source, 'source', 'logmeal')
              .having((s) => s.results[0].scanResult.scannedNutrientsPer100g,
                  'nutrients', isNull) // matched → use DB nutrients
              .having(
                  (s) => s.selectedIndices, 'selectedIndices', {0, 1}),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'unmatched foods without dishId have null matchedFoodId',
        build: () => _buildBloc(masterFoods: []),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Unknown Dish',
            nutrientsPer100g: {'energyKcal': 200.0},
          ),
        ])),
        expect: () => [
          isA<FoodScannerState>(),
          isA<FoodScannerState>()
              .having((s) => s.results.first.scanResult.matchedFoodId,
                  'matchedFoodId', isNull)
              .having((s) => s.results.first.scanResult.scannedName,
                  'scannedName', 'Unknown Dish')
              .having((s) => s.results.first.scanResult.scannedNutrientsPer100g,
                  'nutrients', {'energyKcal': 200.0}),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'matched foods use DB nutrients (null scannedNutrientsPer100g)',
        build: () => _buildBloc(
          masterFoods: [_food(5, 'Apple')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Apple',
            estimatedGrams: 150,
            estimatedKcal: 78,
          ),
        ])),
        expect: () => [
          isA<FoodScannerState>(),
          isA<FoodScannerState>()
              .having((s) => s.results.first.scanResult.matchedFoodId,
                  'matchedFoodId', 5)
              .having((s) => s.results.first.scanResult.scannedNutrientsPer100g,
                  'nutrients', isNull)
              .having((s) => s.results.first.scanResult.estimatedGrams,
                  'estimatedGrams', 150),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // OnBarcodeDetectedAction
    // -----------------------------------------------------------------------

    group('OnBarcodeDetectedAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'returns cached product when available',
        build: () {
          final repo = FakeScannedFoodRepository()
            ..cachedEntity = ScannedFoodEntity(
              lookupKey: '123456',
              localFoodId: -1,
              nameEn: 'Cached Granola',
              brand: 'TestBrand',
              source: 'openfoodfacts',
              paramsJson: jsonEncode({'energyKcal': 400.0, 'proteinLabel': 10.0}),
              scannedAt: 1000,
              detectionMethod: 'barcode',
            );
          return _buildBloc(repo: repo, masterFoods: []);
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '123456')),
        expect: () => [
          // isProcessing = true
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // result from cache
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.results.length, 'results.length', 1)
              .having((s) => s.results.first.scanResult.scannedName,
                  'name', 'Cached Granola')
              .having((s) => s.results.first.scanResult.brand,
                  'brand', 'TestBrand'),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'looks up barcode provider when not cached',
        build: () {
          final bp = FakeBarcodeProvider()
            ..nextResult = BarcodeProduct(
              name: 'Test Bar',
              brand: 'TestCo',
              nutrientsPer100g: {'energyKcal': 300.0},
              servingGrams: 50.0,
              barcode: '999',
            );
          return _buildBloc(barcodeProvider: bp, masterFoods: []);
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '999')),
        expect: () => [
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          isA<FoodScannerState>()
              .having((s) => s.results.length, 'results.length', 1)
              .having((s) => s.results.first.scanResult.scannedName,
                  'name', 'Test Bar')
              .having((s) => s.results.first.scanResult.barcode,
                  'barcode', '999')
              .having((s) => s.results.first.scanResult.estimatedGrams,
                  'servingGrams', 50.0),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'caches unmatched barcode product',
        build: () {
          final bp = FakeBarcodeProvider()
            ..nextResult = BarcodeProduct(
              name: 'Niche Product',
              nutrientsPer100g: {'energyKcal': 100.0},
              barcode: '777',
            );
          final repo = FakeScannedFoodRepository();
          return _buildBloc(
              barcodeProvider: bp, repo: repo, masterFoods: []);
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '777')),
        verify: (bloc) {
          final repo =
              bloc.scannedFoodRepository as FakeScannedFoodRepository;
          expect(repo.lastSaved, isNotNull);
          expect(repo.lastSaved!.lookupKey, '777');
          expect(repo.lastSaved!.nameEn, 'Niche Product');
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits error when barcode product not found',
        build: () {
          final bp = FakeBarcodeProvider()..nextResult = null;
          return _buildBloc(barcodeProvider: bp);
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '000')),
        expect: () => [
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('000')),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'does not cache matched barcode product',
        build: () {
          final bp = FakeBarcodeProvider()
            ..nextResult = BarcodeProduct(
              name: 'Banana',
              nutrientsPer100g: {'energyKcal': 89.0},
              barcode: '888',
            );
          final repo = FakeScannedFoodRepository();
          return _buildBloc(
            barcodeProvider: bp,
            repo: repo,
            masterFoods: [_food(8, 'Banana')],
          );
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '888')),
        verify: (bloc) {
          final repo =
              bloc.scannedFoodRepository as FakeScannedFoodRepository;
          // Should NOT cache because the food was matched
          expect(repo.lastSaved, isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // ToggleFoodSelectionAction
    // -----------------------------------------------------------------------

    group('ToggleFoodSelectionAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'toggles selection on and off',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            ScanResultEntry(
              scanResult: ScanResult(
                scannedName: 'A',
                source: 'test',
                detectionMethod: 'visual',
              ),
            ),
            ScanResultEntry(
              scanResult: ScanResult(
                scannedName: 'B',
                source: 'test',
                detectionMethod: 'visual',
              ),
            ),
          ],
          selectedIndices: {0},
        ),
        act: (bloc) {
          bloc.add(ToggleFoodSelectionAction(index: 1)); // select 1
          bloc.add(ToggleFoodSelectionAction(index: 0)); // deselect 0
        },
        expect: () => [
          // After selecting index 1
          isA<FoodScannerState>()
              .having((s) => s.selectedIndices, 'selected', {0, 1}),
          // After deselecting index 0
          isA<FoodScannerState>()
              .having((s) => s.selectedIndices, 'selected', {1}),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // EditNextSelectedFoodAction
    // -----------------------------------------------------------------------

    group('EditNextSelectedFoodAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'sets editingIndex to first unedited selected food',
        build: () => _buildBloc(masterFoods: []),
        seed: () {
          final entries = [
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'A',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'B',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
          ];
          return FoodScannerState(
            results: entries,
            selectedIndices: {0, 1},
          );
        },
        act: (bloc) => bloc.add(EditNextSelectedFoodAction()),
        expect: () => [
          isA<FoodScannerState>()
              .having((s) => s.editingIndex, 'editingIndex', 0),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // FoodEditedAction
    // -----------------------------------------------------------------------

    group('FoodEditedAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'removes edited food and adjusts indices',
        build: () => _buildBloc(masterFoods: []),
        seed: () {
          final entries = [
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'A',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'B',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'C',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
          ];
          return FoodScannerState(
            results: entries,
            selectedIndices: {0, 1, 2},
            editingIndex: 0,
          );
        },
        act: (bloc) => bloc.add(FoodEditedAction(index: 0)),
        expect: () => [
          isA<FoodScannerState>()
              .having((s) => s.results.length, 'results.length', 2)
              .having(
                  (s) => s.results[0].scanResult.scannedName, 'first', 'B')
              .having((s) => s.selectedIndices, 'selected', {0, 1})
              .having((s) => s.editingIndex, 'editingIndex', isNull)
              .having(
                  (s) => s.editedFoods.length, 'editedFoods.length', 1),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // ResetScannerAction
    // -----------------------------------------------------------------------

    group('ResetScannerAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'resets to initial state',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          isProcessing: true,
          results: [
            ScanResultEntry(
              scanResult: ScanResult(
                  scannedName: 'X',
                  source: 't',
                  detectionMethod: 'visual'),
            ),
          ],
          selectedIndices: {0},
          errorMessage: 'old error',
        ),
        act: (bloc) => bloc.add(ResetScannerAction()),
        expect: () => [
          isA<FoodScannerState>()
              .having((s) => s.isProcessing, 'isProcessing', false)
              .having((s) => s.results, 'results', isEmpty)
              .having((s) => s.selectedIndices, 'selected', isEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // Fuzzy matcher initialization
    // -----------------------------------------------------------------------

    group('fuzzyMatcher', () {
      test('returns empty matcher when not initialized', () {
        final bloc = _buildBloc();
        // Accessing fuzzyMatcher without initializeMatcher should not throw
        final result = bloc.fuzzyMatcher.findBestMatch('Banana');
        expect(result, isNull); // empty matcher has no foods
      });

      test('uses provided master foods after initialization', () {
        final bloc = _buildBloc(masterFoods: [_food(5, 'Orange juice')]);
        final result = bloc.fuzzyMatcher.findBestMatch('Orange juice');
        expect(result, isNotNull);
        expect(result!.food.id, 5);
      });
    });

    // -----------------------------------------------------------------------
    // initializeUnits
    // -----------------------------------------------------------------------

    group('initializeUnits', () {
      test('stores unitsFoodsMaster for later use', () {
        final bloc = _buildBloc();
        final units = UnitsFoodsMaster(unitsFoodsMaster: [
          UnitFoodMaster(id: 1, units: '5,75|6,150'),
        ]);
        // Should not throw
        bloc.initializeUnits(units);
      });
    });
  });
}
