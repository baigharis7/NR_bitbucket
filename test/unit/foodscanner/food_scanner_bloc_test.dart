import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_token_service.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/scan_result_to_ingredient_mapper.dart';
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

class FakeLogMealTokenService implements LogMealTokenService {
  String? nextToken;
  int callCount = 0;

  @override
  Future<String?> getOrCreateToken() async {
    callCount++;
    return nextToken;
  }

  @override
  Future<void> clearToken() async {}

  // Required by Dart since LogMealTokenService has private fields;
  // these are unused in the fake.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUploadFoodEventInteractor implements UploadFoodEventInteractor {
  bool success = true;
  FoodEventSimple? lastInput;
  int callCount = 0;

  @override
  Future<UploadFoodEvent> execute(FoodEventSimple foodEventSimple) async {
    callCount++;
    lastInput = foodEventSimple;
    return UploadFoodEvent(
      foodEventSimple.userId,
      foodEventSimple.eventDate,
      foodEventSimple.eventId,
      foodEventSimple.mealType,
      foodEventSimple.foodName,
      foodEventSimple.comment,
      null,
      null,
      null,
      uploadSuccess: success,
    );
  }
}

class FakeSaveFoodEventInteractor implements SaveFoodEventInteractor {
  int callCount = 0;

  @override
  Future<void> execute(UploadFoodEvent uploadFoodEvent, bool isEdit) async {
    callCount++;
  }
}

class FakeGetUserIdInteractor implements GetUserIdInteractor {
  String userId = 'test-user';

  @override
  String execute() => userId;
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
  FakeLogMealTokenService? tokenService,
  FakeUploadFoodEventInteractor? uploadInteractor,
  FakeSaveFoodEventInteractor? saveInteractor,
  List<FoodItemMaster>? masterFoods,
}) {
  final actualRepo = repo ?? FakeScannedFoodRepository();
  final bloc = FoodScannerBloc(
    barcodeProvider: barcodeProvider ?? FakeBarcodeProvider(),
    scannedFoodRepository: actualRepo,
    scanResultMapper: ScanResultToIngredientMapper(actualRepo),
    uploadFoodEventInteractor:
        uploadInteractor ?? FakeUploadFoodEventInteractor(),
    saveFoodEventInteractor: saveInteractor ?? FakeSaveFoodEventInteractor(),
    getUserIdInteractor: FakeGetUserIdInteractor(),
    visualFoodProvider: visualProvider,
    logMealTokenService: tokenService,
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
              // Barcode scans never auto-fill grams — user always confirms.
              .having((s) => s.results.first.scanResult.estimatedGrams,
                  'estimatedGrams', isNull),
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
        'always caches barcode product regardless of master DB collision',
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
            // Master DB happens to contain a "Banana" entry, but barcode
            // scans are strictly OFF — they never fuzzy-match. The OFF
            // product is always cached as a standalone scanned food.
            masterFoods: [_food(8, 'Banana')],
          );
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '888')),
        verify: (bloc) {
          final repo =
              bloc.scannedFoodRepository as FakeScannedFoodRepository;
          expect(repo.lastSaved, isNotNull);
          expect(repo.lastSaved!.lookupKey, '888');
          expect(repo.lastSaved!.nameEn, 'Banana');
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'does not fuzzy-match barcode results against master DB',
        build: () {
          final bp = FakeBarcodeProvider()
            ..nextResult = BarcodeProduct(
              name: 'Banana',
              nutrientsPer100g: {'energyKcal': 89.0},
              barcode: '321',
            );
          return _buildBloc(
            barcodeProvider: bp,
            masterFoods: [_food(8, 'Banana')],
          );
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '321')),
        expect: () => [
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          isA<FoodScannerState>()
              .having((s) => s.results.first.scanResult.matchedFoodId,
                  'matchedFoodId', isNull)
              .having((s) => s.results.first.scanResult.isMatched,
                  'isMatched', false)
              .having(
                  (s) =>
                      s.results.first.scanResult.scannedNutrientsPer100g,
                  'scannedNutrientsPer100g',
                  isNotNull),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'flags beverage products for drinks-slot routing',
        build: () {
          final bp = FakeBarcodeProvider()
            ..nextResult = BarcodeProduct(
              name: 'Diet Coke',
              nutrientsPer100g: {'energyKcal': 0.0},
              barcode: '5449000000996',
              isBeverage: true,
              servingSizeHint: '330 ml',
            );
          return _buildBloc(barcodeProvider: bp, masterFoods: []);
        },
        act: (bloc) =>
            bloc.add(OnBarcodeDetectedAction(barcode: '5449000000996')),
        expect: () => [
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          isA<FoodScannerState>()
              .having((s) => s.results.first.scanResult.isBeverage,
                  'isBeverage', true)
              .having((s) => s.results.first.scanResult.servingSizeHint,
                  'servingSizeHint', '330 ml'),
        ],
        verify: (bloc) {
          final repo =
              bloc.scannedFoodRepository as FakeScannedFoodRepository;
          // The beverage flag is persisted in the cache so re-scan and
          // edit-later both keep correct routing.
          expect(repo.lastSaved?.isBeverage, true);
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
    // EditTopmostAction
    // -----------------------------------------------------------------------

    ScanResultEntry _matchedEntry(String name, int id, {double? grams}) =>
        ScanResultEntry(
          scanResult: ScanResult(
            scannedName: name,
            source: 'logmeal',
            detectionMethod: 'visual',
            matchedFoodId: id,
            matchedNameEn: name,
            matchedNameEs: name,
            estimatedGrams: grams,
          ),
        );

    group('EditTopmostAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits editingIndex = topmost selected row',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: 100),
            _matchedEntry('Pear', 2, grams: 120),
            _matchedEntry('Plum', 3, grams: 80),
          ],
          selectedIndices: {1, 2},
        ),
        act: (bloc) => bloc.add(EditTopmostAction()),
        expect: () => [
          isA<FoodScannerState>()
              .having((s) => s.editingIndex, 'editingIndex', 1),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'no-op when nothing is selected',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [_matchedEntry('Apple', 1, grams: 100)],
          selectedIndices: const {},
        ),
        act: (bloc) => bloc.add(EditTopmostAction()),
        expect: () => [],
      );
    });

    // -----------------------------------------------------------------------
    // LogTopmostAction
    // -----------------------------------------------------------------------

    group('LogTopmostAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'saves the topmost row and removes it from the list',
        build: () {
          final upload = FakeUploadFoodEventInteractor();
          final save = FakeSaveFoodEventInteractor();
          return _buildBloc(
            masterFoods: [],
            uploadInteractor: upload,
            saveInteractor: save,
          );
        },
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: 100),
            _matchedEntry('Pear', 2, grams: 120),
          ],
          selectedIndices: {0, 1},
        ),
        act: (bloc) => bloc.add(LogTopmostAction()),
        expect: () => [
          isA<FoodScannerState>().having((s) => s.isSaving, 'isSaving', true),
          isA<FoodScannerState>()
              .having((s) => s.results.length, 'results.length', 1)
              .having((s) => s.results[0].scanResult.matchedFoodId,
                  'remaining id', 2)
              .having((s) => s.selectedIndices, 'selected', {0})
              .having((s) => s.saveTick, 'saveTick', 1)
              .having((s) => s.navigateToSummary, 'navigateToSummary', false)
              .having((s) => s.isSaving, 'isSaving', false),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'falls through to edit when topmost row has no grams',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: null),
            _matchedEntry('Pear', 2, grams: 120),
          ],
          selectedIndices: {0, 1},
        ),
        act: (bloc) => bloc.add(LogTopmostAction()),
        expect: () => [
          isA<FoodScannerState>()
              .having((s) => s.editingIndex, 'editingIndex', 0)
              .having((s) => s.results.length, 'results.length', 2),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'raises navigateToSummary when the last row is saved',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [_matchedEntry('Apple', 1, grams: 100)],
          selectedIndices: {0},
        ),
        act: (bloc) => bloc.add(LogTopmostAction()),
        expect: () => [
          isA<FoodScannerState>().having((s) => s.isSaving, 'isSaving', true),
          isA<FoodScannerState>()
              .having((s) => s.results, 'results', isEmpty)
              .having((s) => s.navigateToSummary, 'navigateToSummary', true)
              .having((s) => s.saveTick, 'saveTick', 1),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'surfaces error when upload fails',
        build: () {
          final upload = FakeUploadFoodEventInteractor()..success = false;
          return _buildBloc(
            masterFoods: [],
            uploadInteractor: upload,
          );
        },
        seed: () => FoodScannerState(
          results: [_matchedEntry('Apple', 1, grams: 100)],
          selectedIndices: {0},
        ),
        act: (bloc) => bloc.add(LogTopmostAction()),
        expect: () => [
          isA<FoodScannerState>().having((s) => s.isSaving, 'isSaving', true),
          isA<FoodScannerState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.results.length, 'results.length', 1)
              .having((s) => s.errorMessage, 'errorMessage', contains('Apple')),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // LogAllAction
    // -----------------------------------------------------------------------

    group('LogAllAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'saves complete rows then pauses on the first gramless row for edit',
        build: () {
          final upload = FakeUploadFoodEventInteractor();
          final save = FakeSaveFoodEventInteractor();
          return _buildBloc(
            masterFoods: [],
            uploadInteractor: upload,
            saveInteractor: save,
          );
        },
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: 100),
            _matchedEntry('Pear', 2, grams: null),
            _matchedEntry('Plum', 3, grams: 80),
          ],
          selectedIndices: {0, 1, 2},
        ),
        act: (bloc) => bloc.add(LogAllAction()),
        verify: (bloc) {
          // Apple saved. Pear is still there at index 0 and selected for
          // edit. Plum deferred until the edit completes.
          expect(bloc.state.results.length, 2);
          expect(bloc.state.results[0].scanResult.matchedFoodId, 2);
          expect(bloc.state.results[1].scanResult.matchedFoodId, 3);
          expect(bloc.state.saveTick, 1);
          expect(bloc.state.isSaving, false);
          expect(bloc.state.isLogAllInProgress, true);
          expect(bloc.state.editingIndex, 0);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'saves every row when all have gram estimates',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: 100),
            _matchedEntry('Plum', 3, grams: 80),
          ],
          selectedIndices: {0, 1},
        ),
        act: (bloc) => bloc.add(LogAllAction()),
        verify: (bloc) {
          expect(bloc.state.results, isEmpty);
          expect(bloc.state.saveTick, 2);
          expect(bloc.state.isSaving, false);
          expect(bloc.state.isLogAllInProgress, false);
          expect(bloc.state.navigateToSummary, true);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'pauses immediately for edit when no row has a gram estimate',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Pear', 2, grams: null),
            _matchedEntry('Quince', 4, grams: null),
          ],
          selectedIndices: {0, 1},
        ),
        act: (bloc) => bloc.add(LogAllAction()),
        verify: (bloc) {
          expect(bloc.state.results.length, 2);
          expect(bloc.state.saveTick, 0);
          expect(bloc.state.isLogAllInProgress, true);
          expect(bloc.state.editingIndex, 0);
        },
      );
    });

    // -----------------------------------------------------------------------
    // EditCompletedAction
    // -----------------------------------------------------------------------

    group('EditCompletedAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'removes the edited row without bumping saveTick',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          results: [
            _matchedEntry('Apple', 1, grams: 100),
            _matchedEntry('Pear', 2, grams: 120),
          ],
          selectedIndices: {0, 1},
        ),
        act: (bloc) => bloc.add(EditCompletedAction(index: 0)),
        verify: (bloc) {
          expect(bloc.state.results.length, 1);
          expect(bloc.state.results[0].scanResult.matchedFoodId, 2);
          expect(bloc.state.selectedIndices, {0});
          expect(bloc.state.saveTick, 0);
          expect(bloc.state.hasLoggedSomething, true);
          expect(bloc.state.editingIndex, isNull);
          expect(bloc.state.isLogAllInProgress, false);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'resumes Log all: saves remaining complete rows after edit',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          // Simulates paused Log all: Pear was being edited (index 0), Plum
          // (index 1) still needs to be saved.
          results: [
            _matchedEntry('Pear', 2, grams: 120),
            _matchedEntry('Plum', 3, grams: 80),
          ],
          selectedIndices: {0, 1},
          isLogAllInProgress: true,
        ),
        act: (bloc) => bloc.add(EditCompletedAction(index: 0)),
        verify: (bloc) {
          // Both rows gone: Pear via edit remove, Plum via resumed save.
          expect(bloc.state.results, isEmpty);
          expect(bloc.state.saveTick, 1);
          expect(bloc.state.isLogAllInProgress, false);
          expect(bloc.state.isSaving, false);
          expect(bloc.state.navigateToSummary, true);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'resumes Log all: pauses on the next gramless row',
        build: () => _buildBloc(masterFoods: []),
        seed: () => FoodScannerState(
          // Pear edited (index 0), Quince (index 1) also needs input.
          results: [
            _matchedEntry('Pear', 2, grams: 120),
            _matchedEntry('Quince', 4, grams: null),
          ],
          selectedIndices: {0, 1},
          isLogAllInProgress: true,
        ),
        act: (bloc) => bloc.add(EditCompletedAction(index: 0)),
        verify: (bloc) {
          // Quince remains, now at index 0, teed up for edit.
          expect(bloc.state.results.length, 1);
          expect(bloc.state.results[0].scanResult.matchedFoodId, 4);
          expect(bloc.state.isLogAllInProgress, true);
          expect(bloc.state.editingIndex, 0);
        },
      );
    });

    // -----------------------------------------------------------------------
    // EditCancelledAction
    // -----------------------------------------------------------------------

    group('EditCancelledAction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'clears isLogAllInProgress so a later edit does not auto-resume',
        build: () => _buildBloc(masterFoods: []),
        seed: () => const FoodScannerState(isLogAllInProgress: true),
        act: (bloc) => bloc.add(EditCancelledAction()),
        verify: (bloc) {
          expect(bloc.state.isLogAllInProgress, false);
          expect(bloc.state.isSaving, false);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'is a no-op when no Log all was in progress',
        build: () => _buildBloc(masterFoods: []),
        seed: () => const FoodScannerState(),
        act: (bloc) => bloc.add(EditCancelledAction()),
        expect: () => <FoodScannerState>[],
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

    // -----------------------------------------------------------------------
    // Lazy LogMeal token initialization
    // -----------------------------------------------------------------------

    group('Lazy LogMeal token initialization', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'creates LogMealProvider from token service on first capture',
        build: () {
          final ts = FakeLogMealTokenService()..nextToken = 'per-user-token';
          return _buildBloc(
            tokenService: ts,
            masterFoods: [_food(1, 'Banana')],
          );
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        // The LogMealProvider will be created but the fake image bytes will
        // fail segmentation. We just need to verify the provider was created
        // (i.e. we don't get "Visual recognition not configured").
        expect: () => [
          // isProcessing = true (from lazy init)
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // Scan will fail/error (fake bytes, real HTTP call blocked) but NOT
          // with "Visual recognition not configured"
          isA<FoodScannerState>()
              .having((s) => s.errorMessage, 'errorMessage',
                  isNot('Visual recognition not configured')),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'emits error when token service returns null',
        build: () {
          final ts = FakeLogMealTokenService()..nextToken = null;
          return _buildBloc(tokenService: ts);
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        expect: () => [
          // isProcessing = true (from lazy init attempt)
          isA<FoodScannerState>().having(
              (s) => s.isProcessing, 'isProcessing', true),
          // Falls through to "not configured" since token was null
          isA<FoodScannerState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            'Visual recognition not configured',
          ),
        ],
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'skips token service when visualFoodProvider already set',
        build: () {
          final vp = FakeVisualProvider()
            ..nextResults = [
              VisualFoodResult(name: 'Apple', estimatedGrams: 150),
            ];
          final ts = FakeLogMealTokenService()..nextToken = 'unused-token';
          return _buildBloc(
            visualProvider: vp,
            tokenService: ts,
            masterFoods: [_food(2, 'Apple')],
          );
        },
        act: (bloc) => bloc.add(CapturePhotoAction(imageBytes: [1, 2, 3])),
        verify: (bloc) {
          // Token service should NOT have been called since provider was
          // already provided at construction time.
          // We can't access the fake directly here, so we verify by checking
          // that results came from the FakeVisualProvider (not an error).
          expect(bloc.state.results.length, 1);
          expect(bloc.state.results.first.scanResult.scannedName, 'Apple');
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'does not attempt token fetch when both provider and service are null',
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
    });

    // -----------------------------------------------------------------------
    // Cooking method extraction during matching
    // -----------------------------------------------------------------------

    group('Cooking method extraction', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'strips cooking qualifier and matches base food',
        build: () => _buildBloc(
          masterFoods: [_food(4, 'Chicken breast')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Grilled chicken breast',
            estimatedGrams: 200,
          ),
        ])),
        verify: (bloc) {
          expect(bloc.state.results.length, 1);
          final result = bloc.state.results.first.scanResult;
          expect(result.matchedFoodId, 4);
          expect(result.detectedCookingMethod, 'Grilled');
          expect(result.scannedName, 'Grilled chicken breast');
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'detects fried cooking method',
        build: () => _buildBloc(
          masterFoods: [_food(2, 'White rice')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Fried white rice',
            estimatedGrams: 150,
          ),
        ])),
        verify: (bloc) {
          final result = bloc.state.results.first.scanResult;
          expect(result.matchedFoodId, 2);
          expect(result.detectedCookingMethod, 'Fried');
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'no cooking method when name has none',
        build: () => _buildBloc(
          masterFoods: [_food(8, 'Banana')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Banana',
            estimatedGrams: 120,
          ),
        ])),
        verify: (bloc) {
          final result = bloc.state.results.first.scanResult;
          expect(result.matchedFoodId, 8);
          expect(result.detectedCookingMethod, isNull);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'falls back to original name if cleaned name does not match',
        build: () => _buildBloc(
          masterFoods: [_food(10, 'Steamed broccoli')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Steamed broccoli',
            estimatedGrams: 100,
          ),
        ])),
        verify: (bloc) {
          // "steamed broccoli" with cooking stripped → "broccoli"
          // "broccoli" doesn't match "Steamed broccoli" via exact,
          // but the fallback to the original name does match
          final result = bloc.state.results.first.scanResult;
          expect(result.matchedFoodId, 10);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Missing grams handling
    // -----------------------------------------------------------------------

    group('Missing grams', () {
      blocTest<FoodScannerBloc, FoodScannerState>(
        'preserves null estimatedGrams when LogMeal provides none',
        build: () => _buildBloc(
          masterFoods: [_food(8, 'Banana')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Banana',
            estimatedGrams: null,
          ),
        ])),
        verify: (bloc) {
          final result = bloc.state.results.first.scanResult;
          expect(result.matchedFoodId, 8);
          expect(result.estimatedGrams, isNull);
        },
      );

      blocTest<FoodScannerBloc, FoodScannerState>(
        'passes through gram estimate when provided',
        build: () => _buildBloc(
          masterFoods: [_food(8, 'Banana')],
        ),
        act: (bloc) => bloc.add(OnVisualFoodDetectedAction(candidates: [
          DetectedFoodCandidate(
            name: 'Banana',
            estimatedGrams: 120,
          ),
        ])),
        verify: (bloc) {
          final result = bloc.state.results.first.scanResult;
          expect(result.estimatedGrams, 120);
        },
      );
    });
  });
}
