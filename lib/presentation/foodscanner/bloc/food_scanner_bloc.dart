import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/food_fuzzy_matcher.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodscanner/bloc/food_scanner_state.dart';

class FoodScannerBloc
    extends BaseBloc<FoodScannerAction, FoodScannerState> {
  final BarcodeNutritionProvider barcodeProvider;
  final ScannedFoodRepository scannedFoodRepository;
  final VisualFoodProvider? visualFoodProvider;
  FoodFuzzyMatcher? _fuzzyMatcher;

  /// Provide the master food list so the fuzzy matcher can be initialized.
  /// Call this when opening the scanner screen (master files should be loaded
  /// by then).
  void initializeMatcher(List<FoodItemMaster> masterFoods) {
    _fuzzyMatcher = FoodFuzzyMatcher(masterFoods);
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
    this.visualFoodProvider,
  }) : super(const FoodScannerState()) {
    on<OnVisualFoodDetectedAction>(_onVisualFoodDetected);
    on<OnBarcodeDetectedAction>(_onBarcodeDetected);
    on<ToggleFoodSelectionAction>(_onToggleSelection);
    on<LogSelectedFoodsAction>(_onLogSelected);
    on<EditNextSelectedFoodAction>(_onEditNext);
    on<FoodEditedAction>(_onFoodEdited);
    on<CapturePhotoAction>(_onCapturePhoto);
    on<ResetScannerAction>(_onReset);
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

    for (final candidate in action.candidates) {
      final match = fuzzyMatcher.findBestMatch(candidate.name);

      final scanResult = ScanResult(
        scannedName: candidate.name,
        source: 'passio',
        detectionMethod: 'visual',
        matchedFoodId: match?.food.id,
        matchedNameEn: match?.food.en,
        matchedNameEs: match?.food.es,
        matchedGroup: match?.food.group,
        matchScore: match?.score,
        scannedNutrientsPer100g:
            match == null ? candidate.nutrientsPer100g : null,
        passioFoodId: candidate.passioFoodId,
        estimatedGrams: candidate.estimatedGrams,
        estimatedKcal: candidate.estimatedKcal,
      );

      results.add(ScanResultEntry(scanResult: scanResult, isSelected: true));
    }

    emit(state.copyWith(
      isProcessing: false,
      results: results,
      selectedIndices: Set<int>.from(
        List.generate(results.length, (i) => i),
      ),
    ));
  }

  // ---------------------------------------------------------------------------
  // Barcode detection
  // ---------------------------------------------------------------------------

  Future<void> _onBarcodeDetected(
    OnBarcodeDetectedAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, errorMessage: () => null));

    // Check local cache first
    final cached =
        await scannedFoodRepository.findByLookupKey(action.barcode);
    if (cached != null) {
      final nutrientMap =
          (jsonDecode(cached.paramsJson) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble()));

      // Still try to fuzzy-match
      final match = fuzzyMatcher.findBestMatch(cached.nameEn);
      final scanResult = ScanResult(
        scannedName: cached.nameEn,
        brand: cached.brand,
        source: cached.source,
        detectionMethod: 'barcode',
        matchedFoodId: match?.food.id,
        matchedNameEn: match?.food.en,
        matchedNameEs: match?.food.es,
        matchedGroup: match?.food.group,
        matchScore: match?.score,
        scannedNutrientsPer100g: match == null ? nutrientMap : null,
        barcode: action.barcode,
        estimatedKcal: nutrientMap['energyKcal'],
      );

      emit(state.copyWith(
        isProcessing: false,
        results: [ScanResultEntry(scanResult: scanResult, isSelected: true)],
        selectedIndices: {0},
      ));
      return;
    }

    // Call barcode provider (Passio or OFF)
    final product = await barcodeProvider.lookupBarcode(action.barcode);
    if (product == null) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: () => 'Product not found for barcode ${action.barcode}',
      ));
      return;
    }

    // Fuzzy match against our DB
    final match = fuzzyMatcher.findBestMatch(product.name);

    final scanResult = ScanResult(
      scannedName: product.name,
      brand: product.brand,
      source: 'passio', // or 'openfoodfacts' depending on provider
      detectionMethod: 'barcode',
      matchedFoodId: match?.food.id,
      matchedNameEn: match?.food.en,
      matchedNameEs: match?.food.es,
      matchedGroup: match?.food.group,
      matchScore: match?.score,
      scannedNutrientsPer100g: match == null ? product.nutrientsPer100g : null,
      barcode: action.barcode,
      estimatedGrams: product.servingGrams,
      estimatedKcal: product.nutrientsPer100g['energyKcal'],
    );

    // Cache unmatched foods locally for next time
    if (!scanResult.isMatched) {
      final localId = await scannedFoodRepository.nextLocalFoodId();
      await scannedFoodRepository.saveScannedFood(ScannedFoodEntity(
        lookupKey: action.barcode,
        localFoodId: localId,
        nameEn: product.name,
        brand: product.brand,
        source: 'passio',
        paramsJson: jsonEncode(product.nutrientsPer100g),
        scannedAt: DateTime.now().millisecondsSinceEpoch,
        detectionMethod: 'barcode',
      ));
    }

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
  // Log selected foods (no edit)
  // ---------------------------------------------------------------------------

  void _onLogSelected(
    LogSelectedFoodsAction action,
    Emitter<FoodScannerState> emit,
  ) {
    // The UI reads state.selectedIndices + state.results to build
    // FoodInEvent/FoodInFavorite objects and dispatch to AddFoodEventBloc.
    // This action just signals the UI to proceed.
  }

  // ---------------------------------------------------------------------------
  // Sequential edit flow
  // ---------------------------------------------------------------------------

  void _onEditNext(
    EditNextSelectedFoodAction action,
    Emitter<FoodScannerState> emit,
  ) {
    // Find the first selected index that hasn't been edited yet
    final unedited = state.selectedIndices
        .where((i) => !state.editedFoods.contains(state.results[i]))
        .toList()
      ..sort();

    if (unedited.isEmpty) return;

    emit(state.copyWith(editingIndex: () => unedited.first));
  }

  void _onFoodEdited(
    FoodEditedAction action,
    Emitter<FoodScannerState> emit,
  ) {
    final edited = List<ScanResultEntry>.from(state.editedFoods)
      ..add(state.results[action.index]);

    // Remove from results list
    final newResults = List<ScanResultEntry>.from(state.results)
      ..removeAt(action.index);

    // Adjust selected indices
    final newSelection = <int>{};
    for (final i in state.selectedIndices) {
      if (i == action.index) continue;
      newSelection.add(i > action.index ? i - 1 : i);
    }

    emit(state.copyWith(
      results: newResults,
      selectedIndices: newSelection,
      editingIndex: () => null,
      editedFoods: edited,
    ));
  }

  // ---------------------------------------------------------------------------
  // Capture photo → Claude Vision
  // ---------------------------------------------------------------------------

  Future<void> _onCapturePhoto(
    CapturePhotoAction action,
    Emitter<FoodScannerState> emit,
  ) async {
    if (visualFoodProvider == null) {
      emit(state.copyWith(
        errorMessage: () => 'Visual recognition not configured',
      ));
      return;
    }

    emit(state.copyWith(isProcessing: true, errorMessage: () => null));

    try {
      final results = await visualFoodProvider!
          .identifyFoods(Uint8List.fromList(action.imageBytes));

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
              ))
          .toList();

      add(OnVisualFoodDetectedAction(candidates: candidates));
    } on LogMealException catch (e, stack) {
      debugPrint('[FoodScanner] LogMeal error: $e');
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
      debugPrint('[FoodScanner] Unexpected error: $e');
      CrashlyticsService.record(e, stack, context: {
        'source': 'food_scanner_capture',
      });
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: () => 'Scan error: $e',
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
