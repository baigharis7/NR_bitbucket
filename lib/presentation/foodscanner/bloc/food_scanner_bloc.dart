import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_provider.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_token_service.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/save_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/network_error_utils.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/upload_food_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/scan_result_to_ingredient_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/food_fuzzy_matcher.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_mapper_service.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_state.dart';

class FoodScannerBloc
    extends BaseBloc<FoodScannerAction, FoodScannerState> {
  final BarcodeNutritionProvider barcodeProvider;
  final ScannedFoodRepository scannedFoodRepository;
  final ScanResultToIngredientMapper scanResultMapper;
  final UploadFoodEventInteractor uploadFoodEventInteractor;
  final SaveFoodEventInteractor saveFoodEventInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  VisualFoodProvider? visualFoodProvider;
  final LogMealTokenService? _logMealTokenService;
  FoodFuzzyMatcher? _fuzzyMatcher;
  UnitsFoodsMaster? _unitsFoodsMaster;
  int _mealType = 0;

  /// Provide the master food list so the fuzzy matcher can be initialized.
  /// Call this when opening the scanner screen (master files should be loaded
  /// by then).
  void initializeMatcher(List<FoodItemMaster> masterFoods) {
    _fuzzyMatcher = FoodFuzzyMatcher(masterFoods);
  }

  /// Provide the units-foods master data for smart unit matching.
  void initializeUnits(UnitsFoodsMaster unitsFoodsMaster) {
    _unitsFoodsMaster = unitsFoodsMaster;
  }

  FoodFuzzyMatcher get fuzzyMatcher {
    if (_fuzzyMatcher == null) {
      // Fallback: empty matcher (no matches will be found).
      _fuzzyMatcher = FoodFuzzyMatcher([]);
    }
    return _fuzzyMatcher!;
  }

  FoodScannerBloc({
    required this.barcodeProvider,
    required this.scannedFoodRepository,
    required this.scanResultMapper,
    required this.uploadFoodEventInteractor,
    required this.saveFoodEventInteractor,
    required this.getUserIdInteractor,
    this.visualFoodProvider,
    LogMealTokenService? logMealTokenService,
  })  : _logMealTokenService = logMealTokenService,
        super(const FoodScannerState()) {
    on<InitializeMealTypeAction>(_onInitializeMealType);
    on<OnVisualFoodDetectedAction>(_onVisualFoodDetected);
    on<OnBarcodeDetectedAction>(_onBarcodeDetected);
    on<ToggleFoodSelectionAction>(_onToggleSelection);
    on<LogTopmostAction>(_onLogTopmost);
    on<LogAllAction>(_onLogAll);
    on<EditTopmostAction>(_onEditTopmost);
    on<EditCompletedAction>(_onEditCompleted);
    on<EditCancelledAction>(_onEditCancelled);
    on<ClearEditingAction>(_onClearEditing);
    on<ClearNavigateToSummaryAction>(_onClearNavigateToSummary);
    on<CapturePhotoAction>(_onCapturePhoto);
    on<ResetScannerAction>(_onReset);
  }

  void _onInitializeMealType(
    InitializeMealTypeAction action,
    Emitter<FoodScannerState> emit,
  ) {
    _mealType = action.mealType;
  }

  // ---------------------------------------------------------------------------
  // Visual food detection
  // ---------------------------------------------------------------------------

  Future<void> _onVisualFoodDetected(
    OnVisualFoodDetectedAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, errorMessage: () => null));

    final results = <ScanResultEntry>[];

    // Collect unmatched candidates that need ingredient breakdown
    final unmatchedWithDishId = <int, DetectedFoodCandidate>{};

    for (final candidate in action.candidates) {
      // Strip cooking method qualifiers before matching
      final (cleanedName, cookingMethod) =
          FoodFuzzyMatcher.extractCookingMethod(candidate.name);

      // Try matching with cleaned name first, fall back to original
      var match = fuzzyMatcher.findBestMatch(cleanedName);
      match ??= fuzzyMatcher.findBestMatch(candidate.name);

      if (match != null) {
        // Matched in our DB — use our nutrients, LogMeal's gram estimate
        debugPrint('[FoodScanner] Matched "${candidate.name}" → '
            '${match.food.en} (id=${match.food.id}, score=${match.score})'
            '${cookingMethod != null ? ' [cooking: $cookingMethod]' : ''}');

        results.add(ScanResultEntry(
          scanResult: ScanResult(
            scannedName: candidate.name,
            source: 'logmeal',
            detectionMethod: 'visual',
            matchedFoodId: match.food.id,
            matchedNameEn: match.food.en,
            matchedNameEs: match.food.es,
            matchedGroup: match.food.group,
            matchScore: match.score,
            scannedNutrientsPer100g: null, // Use our DB nutrients
            estimatedGrams: candidate.estimatedGrams,
            estimatedKcal: candidate.estimatedKcal,
            detectedCookingMethod: cookingMethod,
          ),
          isSelected: true,
        ));
      } else if (candidate.logmealDishId != null) {
        // Not matched — queue for ingredient breakdown
        unmatchedWithDishId[candidate.logmealDishId!] = candidate;
        debugPrint('[FoodScanner] Unmatched "${candidate.name}" — '
            'will try ingredient breakdown (dishId=${candidate.logmealDishId})');
      } else {
        // Not matched, no dish ID — use provided nutrients directly
        debugPrint('[FoodScanner] Unmatched "${candidate.name}" — '
            'no dishId, using provided nutrients');
        results.add(ScanResultEntry(
          scanResult: ScanResult(
            scannedName: candidate.name,
            source: 'logmeal',
            detectionMethod: 'visual',
            scannedNutrientsPer100g: candidate.nutrientsPer100g,
            estimatedGrams: candidate.estimatedGrams,
            estimatedKcal: candidate.estimatedKcal,
          ),
          isSelected: true,
        ));
      }
    }

    // --- Cascading ingredient resolution for unmatched dishes ---
    if (unmatchedWithDishId.isNotEmpty &&
        visualFoodProvider is LogMealProvider) {
      final logmeal = visualFoodProvider as LogMealProvider;
      final imageId = logmeal.lastImageId;

      if (imageId != null) {
        await _resolveUnmatchedDishes(
          logmeal, imageId, unmatchedWithDishId, results,
        );
      } else {
        // No imageId — fall back to adding unmatched dishes with no nutrients
        for (final candidate in unmatchedWithDishId.values) {
          results.add(ScanResultEntry(
            scanResult: ScanResult(
              scannedName: candidate.name,
              source: 'logmeal',
              detectionMethod: 'visual',
              scannedNutrientsPer100g: candidate.nutrientsPer100g,
              estimatedGrams: candidate.estimatedGrams,
              estimatedKcal: candidate.estimatedKcal,
            ),
            isSelected: true,
          ));
        }
      }
    }

    emit(state.copyWith(
      isProcessing: false,
      results: results,
      selectedIndices: Set<int>.from(
        List.generate(results.length, (i) => i),
      ),
    ));
  }

  /// For unmatched dishes: fetch ingredients from LogMeal, fuzzy-match each
  /// ingredient against our DB, and only fetch LogMeal nutrition for truly
  /// unmatched ingredients.
  Future<void> _resolveUnmatchedDishes(
    LogMealProvider logmeal,
    int imageId,
    Map<int, DetectedFoodCandidate> unmatchedDishes,
    List<ScanResultEntry> results,
  ) async {
    try {
      final ingredients = await logmeal.getIngredients(imageId);

      if (ingredients.isEmpty) {
        debugPrint('[FoodScanner] No ingredients returned — '
            'fetching LogMeal nutrition for unmatched dishes');
        // Fall back to fetching nutrition for the whole image
        await _addUnmatchedWithLogMealNutrition(
          logmeal, imageId, unmatchedDishes.values.toList(), results,
        );
        return;
      }

      debugPrint('[FoodScanner] Got ${ingredients.length} ingredients');

      // Try to match each ingredient against our DB
      bool hasUnmatchedIngredients = false;

      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String? ?? '';
        if (name.isEmpty) continue;

        final quantity = (ingredient['quantity'] as num?)?.toDouble();
        final match = fuzzyMatcher.findBestMatch(name);

        if (match != null) {
          debugPrint('[FoodScanner] Ingredient "$name" matched → '
              '${match.food.en} (id=${match.food.id})');
          results.add(ScanResultEntry(
            scanResult: ScanResult(
              scannedName: name,
              source: 'logmeal',
              detectionMethod: 'visual',
              matchedFoodId: match.food.id,
              matchedNameEn: match.food.en,
              matchedNameEs: match.food.es,
              matchedGroup: match.food.group,
              matchScore: match.score,
              scannedNutrientsPer100g: null,
              estimatedGrams: quantity,
            ),
            isSelected: true,
          ));
        } else {
          hasUnmatchedIngredients = true;
          debugPrint('[FoodScanner] Ingredient "$name" unmatched — '
              'will use LogMeal nutrition');
        }
      }

      // For unmatched ingredients, fetch LogMeal nutrition
      if (hasUnmatchedIngredients) {
        final nutritionResponse =
            await logmeal.getNutritionForImage(imageId);
        Map<String, double>? mappedNutrients;
        if (nutritionResponse != null) {
          mappedNutrients =
              NutrientMapperService.mapFromLogMealResponse(nutritionResponse);
          if (mappedNutrients.isEmpty) {
            debugPrint('[FoodScanner] LogMeal nutrition response had no '
                'recognizable nutrients (keys: ${nutritionResponse.keys.toList()})');
          } else {
            debugPrint('[FoodScanner] Mapped ${mappedNutrients.length} '
                'LogMeal nutrients: ${mappedNutrients.keys.toList()}');
          }
        }

        for (final ingredient in ingredients) {
          final name = ingredient['name'] as String? ?? '';
          if (name.isEmpty) continue;

          final match = fuzzyMatcher.findBestMatch(name);
          if (match != null) continue; // Already added above

          final quantity = (ingredient['quantity'] as num?)?.toDouble();
          results.add(ScanResultEntry(
            scanResult: ScanResult(
              scannedName: name,
              source: 'logmeal',
              detectionMethod: 'visual',
              scannedNutrientsPer100g: mappedNutrients,
              estimatedGrams: quantity,
            ),
            isSelected: true,
          ));
        }
      }
    } catch (e) {
      debugPrint('[FoodScanner] Ingredient resolution error: $e');
      // Fall back: add the original unmatched dishes with no nutrients
      for (final candidate in unmatchedDishes.values) {
        results.add(ScanResultEntry(
          scanResult: ScanResult(
            scannedName: candidate.name,
            source: 'logmeal',
            detectionMethod: 'visual',
            scannedNutrientsPer100g: candidate.nutrientsPer100g,
            estimatedGrams: candidate.estimatedGrams,
            estimatedKcal: candidate.estimatedKcal,
          ),
          isSelected: true,
        ));
      }
    }
  }

  /// Fetch LogMeal nutrition for the image and add unmatched dishes
  /// with mapped nutrients.
  Future<void> _addUnmatchedWithLogMealNutrition(
    LogMealProvider logmeal,
    int imageId,
    List<DetectedFoodCandidate> candidates,
    List<ScanResultEntry> results,
  ) async {
    final nutritionResponse = await logmeal.getNutritionForImage(imageId);
    Map<String, double>? mappedNutrients;
    if (nutritionResponse != null) {
      mappedNutrients =
          NutrientMapperService.mapFromLogMeal(nutritionResponse);
    }

    for (final candidate in candidates) {
      results.add(ScanResultEntry(
        scanResult: ScanResult(
          scannedName: candidate.name,
          source: 'logmeal',
          detectionMethod: 'visual',
          scannedNutrientsPer100g:
              mappedNutrients ?? candidate.nutrientsPer100g,
          estimatedGrams: candidate.estimatedGrams,
          estimatedKcal: candidate.estimatedKcal,
        ),
        isSelected: true,
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Barcode detection
  // ---------------------------------------------------------------------------

  Future<void> _onBarcodeDetected(
    OnBarcodeDetectedAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, errorMessage: () => null));

    // Cache hit — render the cached OFF snapshot directly. Barcode scans
    // are strictly OFF: never fuzzy-match against the master DB, never
    // auto-estimate grams. The user always confirms the amount.
    final cached =
        await scannedFoodRepository.findByLookupKey(action.barcode);
    Map<String, double>? nutrientMap;
    if (cached != null) {
      try {
        nutrientMap =
            (jsonDecode(cached.paramsJson) as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (e) {
        // Corrupt or legacy cache row — discard and fall through to a
        // fresh OFF lookup instead of crashing.
        debugPrint('[FoodScanner] Corrupt barcode cache for ${action.barcode}: $e');
        nutrientMap = null;
      }
    }
    if (cached != null && nutrientMap != null) {
      final scanResult = ScanResult(
        scannedName: cached.nameEn,
        brand: cached.brand,
        source: cached.source,
        detectionMethod: 'barcode',
        scannedNutrientsPer100g: nutrientMap,
        barcode: action.barcode,
        estimatedKcal: nutrientMap['energyKcal'],
        isBeverage: cached.isBeverage,
      );

      emit(state.copyWith(
        isProcessing: false,
        results: [ScanResultEntry(scanResult: scanResult, isSelected: true)],
        selectedIndices: {0},
      ));
      return;
    }

    // Cache miss — hit the OFF provider.
    final product = await barcodeProvider.lookupBarcode(action.barcode);
    if (product == null) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: () => 'Product not found for barcode ${action.barcode}',
      ));
      return;
    }

    const source = 'openfoodfacts';
    final scanResult = ScanResult(
      scannedName: product.name,
      brand: product.brand,
      source: source,
      detectionMethod: 'barcode',
      scannedNutrientsPer100g: product.nutrientsPer100g,
      barcode: action.barcode,
      // No gram estimate for barcodes — user always enters the amount.
      estimatedKcal: product.nutrientsPer100g['energyKcal'],
      isBeverage: product.isBeverage,
      servingSizeHint: product.servingSizeHint,
    );

    // Always cache barcode scans so re-scan and edit-later work without
    // re-hitting OFF and so the negative food id is stable.
    final localId = await scannedFoodRepository.nextLocalFoodId();
    await scannedFoodRepository.saveScannedFood(ScannedFoodEntity(
      lookupKey: action.barcode,
      localFoodId: localId,
      nameEn: product.name,
      brand: product.brand,
      source: source,
      paramsJson: jsonEncode(product.nutrientsPer100g),
      scannedAt: DateTime.now().millisecondsSinceEpoch,
      detectionMethod: 'barcode',
      isBeverage: product.isBeverage,
    ));

    emit(state.copyWith(
      isProcessing: false,
      results: [ScanResultEntry(scanResult: scanResult, isSelected: true)],
      selectedIndices: {0},
    ));
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void _onToggleSelection(
    ToggleFoodSelectionAction action,
    Emitter<FoodScannerState> emit,
  ) {
    final newSelection = Set<int>.from(state.selectedIndices);
    if (newSelection.contains(action.index)) {
      newSelection.remove(action.index);
    } else {
      newSelection.add(action.index);
    }
    emit(state.copyWith(selectedIndices: newSelection));
  }

  // ---------------------------------------------------------------------------
  // Save flow (Log / Log all / Edit)
  // ---------------------------------------------------------------------------

  Future<void> _onLogTopmost(
    LogTopmostAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    final index = state.topmostSelectedIndex;
    if (index == null || index >= state.results.length) return;

    final scan = state.results[index].scanResult;
    if (scan.estimatedGrams == null) {
      // Can't save without a gram amount — fall through to edit.
      emit(state.copyWith(editingIndex: () => index));
      return;
    }

    await _saveRow(index, emit);
  }

  Future<void> _onLogAll(
    LogAllAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    if (!state.hasSelection) return;
    emit(state.copyWith(
      isLogAllInProgress: true,
      isSaving: true,
      errorMessage: () => null,
    ));
    await _runLogAllLoop(emit);
  }

  /// Walks the currently-selected rows top-down: rows with a gram estimate
  /// save directly; on the first row without one we pause the loop and open
  /// the edit screen. The loop resumes from [_onEditCompleted] so the user
  /// never has to re-tap "Log all" between items.
  Future<void> _runLogAllLoop(Emitter<FoodScannerState> emit) async {
    while (state.selectedIndices.isNotEmpty) {
      // Work through the list in display order so the visual topmost
      // item is always the one being acted on.
      final sorted = state.selectedIndices.toList()..sort();
      final index = sorted.first;

      if (index >= state.results.length) {
        // Stale selection — drop it and keep going.
        final cleaned = Set<int>.from(state.selectedIndices)..remove(index);
        emit(state.copyWith(selectedIndices: cleaned));
        continue;
      }

      final scan = state.results[index].scanResult;
      if (scan.estimatedGrams == null) {
        // Needs user input. Pause the batch and hand off to the edit
        // screen; _onEditCompleted will resume us.
        emit(state.copyWith(
          isSaving: false,
          editingIndex: () => index,
        ));
        return;
      }

      await _saveRow(index, emit);
      // _saveRow emits isSaving: false via _removeRow after each save.
      // Re-assert the spinner while the batch is still running.
      if (state.selectedIndices.isNotEmpty) {
        emit(state.copyWith(isSaving: true));
      }
    }

    // Batch finished.
    emit(state.copyWith(
      isSaving: false,
      isLogAllInProgress: false,
    ));
  }

  void _onEditTopmost(
    EditTopmostAction action,
    Emitter<FoodScannerState> emit,
  ) {
    final index = state.topmostSelectedIndex;
    if (index == null || index >= state.results.length) return;
    emit(state.copyWith(editingIndex: () => index));
  }

  Future<void> _onEditCompleted(
    EditCompletedAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    // Don't bump saveTick — the pushed AddFoodEventScreen already
    // showed its own confirmation dialog.
    _removeRow(action.index, emit, bumpSaveTick: false);

    if (state.isLogAllInProgress) {
      // Resume the batch with the spinner re-armed.
      emit(state.copyWith(isSaving: true));
      await _runLogAllLoop(emit);
    }
  }

  void _onEditCancelled(
    EditCancelledAction action,
    Emitter<FoodScannerState> emit,
  ) {
    // User backed out of the edit screen — abort any in-flight Log all
    // batch so a later manual edit doesn't unexpectedly resume it.
    if (state.isLogAllInProgress) {
      emit(state.copyWith(
        isLogAllInProgress: false,
        isSaving: false,
      ));
    }
  }

  void _onClearEditing(
    ClearEditingAction action,
    Emitter<FoodScannerState> emit,
  ) {
    emit(state.copyWith(editingIndex: () => null));
  }

  void _onClearNavigateToSummary(
    ClearNavigateToSummaryAction action,
    Emitter<FoodScannerState> emit,
  ) {
    emit(state.copyWith(navigateToSummary: false));
  }

  /// Map the row's scan result to an ingredient, upload and save a
  /// FoodEvent, then drop the row from the list.
  Future<void> _saveRow(int index, Emitter<FoodScannerState> emit) async {
    final entry = state.results[index];
    final scan = entry.scanResult;

    emit(state.copyWith(isSaving: true, errorMessage: () => null));

    try {
      final ingredient = await scanResultMapper.toIngredient(scan);
      final foodName = scan.isMatched
          ? (scan.matchedNameEn ?? scan.scannedName)
          : scan.scannedName;
      final userId = getUserIdInteractor.execute();
      final eventDateMs = DateTime.now().millisecondsSinceEpoch;
      final foodInEvent = FoodInEvent(
        id: ingredient.id,
        qty: ingredient.qty,
        unit: ingredient.unit,
        cookingMethod: ingredient.cookingMethod,
        unitsEquivalences: ingredient.unitsEquivalences,
      );
      final foodEventSimple = FoodEventSimple(
        userId: userId,
        eventDate: eventDateMs,
        eventId: eventDateMs,
        mealType: _mealType,
        foodName: foodName,
        comment: null,
        ingredients: scan.isBeverage ? [] : [foodInEvent],
        drinks: scan.isBeverage ? [foodInEvent] : [],
      );

      final uploadResult = await uploadFoodEventInteractor.execute(foodEventSimple);
      if (!uploadResult.uploadSuccess) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: () => 'Failed to save "$foodName". Please try again.',
        ));
        return;
      }

      await saveFoodEventInteractor.execute(uploadResult, false);
      DashboardEventBus.instance.notify(DataChangedCategory.food);

      _removeRow(index, emit, bumpSaveTick: true);
    } catch (e, stack) {
      CrashlyticsService.record(e, stack, context: {
        'source': 'food_scanner_save_row',
        'scannedName': scan.scannedName,
      });
      emit(state.copyWith(
        isSaving: false,
        errorMessage: () => 'Could not save "${scan.scannedName}".',
      ));
    }
  }

  /// Drop a row from [FoodScannerState.results] and re-index
  /// [FoodScannerState.selectedIndices]. Optionally bumps [saveTick] so
  /// the screen can show a success splash.
  void _removeRow(
    int index,
    Emitter<FoodScannerState> emit, {
    bool bumpSaveTick = false,
  }) {
    if (index < 0 || index >= state.results.length) return;
    final newResults = List<ScanResultEntry>.from(state.results)
      ..removeAt(index);

    final newSelection = <int>{};
    for (final i in state.selectedIndices) {
      if (i == index) continue;
      newSelection.add(i > index ? i - 1 : i);
    }

    emit(state.copyWith(
      results: newResults,
      selectedIndices: newSelection,
      isSaving: false,
      saveTick: bumpSaveTick ? state.saveTick + 1 : state.saveTick,
      hasLoggedSomething: true,
      editingIndex: () => null,
      navigateToSummary: newResults.isEmpty,
    ));
  }

  // ---------------------------------------------------------------------------
  // Capture photo → Claude Vision
  // ---------------------------------------------------------------------------

  Future<void> _onCapturePhoto(
    CapturePhotoAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    // Lazily create LogMealProvider with per-user token on first scan
    if (visualFoodProvider == null && _logMealTokenService != null) {
      emit(state.copyWith(isProcessing: true, errorMessage: () => null));
      final token = await _logMealTokenService!.getOrCreateToken();
      if (token != null) {
        visualFoodProvider = LogMealProvider(apiToken: token);
      }
    }

    if (visualFoodProvider == null) {
      emit(state.copyWith(
        errorMessage: () => 'Visual recognition not configured',
      ));
      return;
    }

    emit(state.copyWith(isProcessing: true, errorMessage: () => null));
    CrashlyticsService.instance.log('Scanner: capture photo (${action.imageBytes.length} bytes)');

    try {
      final results = await visualFoodProvider!
          .identifyFoods(Uint8List.fromList(action.imageBytes));

      CrashlyticsService.instance.log('Scanner: identifyFoods returned ${results.length} results');

      if (results.isEmpty) {
        emit(state.copyWith(
          isProcessing: false,
          errorMessage: () => 'No food detected in the image',
        ));
        return;
      }

      // Convert VisualFoodResult → DetectedFoodCandidate and dispatch
      final candidates = results
          .map((r) => DetectedFoodCandidate(
                name: r.name,
                estimatedGrams: r.estimatedGrams,
                estimatedKcal: r.estimatedKcal,
                confidence: r.confidence,
                logmealDishId: r.logmealDishId,
              ))
          .toList();

      CrashlyticsService.instance.log(
        'Scanner: ${candidates.map((c) => '${c.name}(${c.estimatedGrams}g)').join(', ')}',
      );

      add(OnVisualFoodDetectedAction(candidates: candidates));
    } on LogMealException catch (e, stack) {
      CrashlyticsService.instance.log('Scanner: LogMeal error ${e.statusCode}');
      CrashlyticsService.record(e, stack, context: {
        'statusCode': e.statusCode.toString(),
        'responseBody': e.responseBody.length > 500
            ? e.responseBody.substring(0, 500)
            : e.responseBody,
      });
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: () => 'Scan failed (${e.statusCode}): ${e.responseBody}',
      ));
    } catch (e, stack) {
      CrashlyticsService.instance.log('Scanner: unexpected error: $e');
      CrashlyticsService.record(e, stack, context: {
        'source': 'food_scanner_capture',
      });
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: () => isNetworkError(e)
            ? 'No internet connection. Please check your network and try again.'
            : 'Scan error: $e',
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void _onReset(
    ResetScannerAction action,
    Emitter<FoodScannerState> emit,
  ) {
    emit(const FoodScannerState());
  }
}
