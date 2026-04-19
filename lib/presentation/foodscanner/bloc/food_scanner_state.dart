import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';

class FoodScannerState {
  /// Whether the scanner is processing a detection.
  final bool isProcessing;

  /// Whether the scanner is currently saving a food event.
  final bool isSaving;

  /// Results from the most recent scan.
  final List<ScanResultEntry> results;

  /// Which results the user has checked for action (by index).
  final Set<int> selectedIndices;

  /// Index of a row the UI should push into the edit screen, once.
  /// Cleared after the listener consumes it.
  final int? editingIndex;

  /// Monotonic counter bumped after every successful Log / Log all
  /// save so the screen can show a success splash. Not bumped by the
  /// edit flow, which shows its own confirmation dialog inside the
  /// pushed AddFoodEventScreen.
  final int saveTick;

  /// Whether at least one row was persisted (via direct log or edit
  /// save) in this scanner session. Used by the close button to
  /// decide whether to return `true` (navigate to summary) to the
  /// caller.
  final bool hasLoggedSomething;

  /// Whether the scanner should pop and land on the meal summary.
  /// Raised when the row list empties after a Log all / final Log.
  final bool navigateToSummary;

  /// Error message to display, if any.
  final String? errorMessage;

  const FoodScannerState({
    this.isProcessing = false,
    this.isSaving = false,
    this.results = const [],
    this.selectedIndices = const {},
    this.editingIndex,
    this.saveTick = 0,
    this.hasLoggedSomething = false,
    this.navigateToSummary = false,
    this.errorMessage,
  });

  FoodScannerState copyWith({
    bool? isProcessing,
    bool? isSaving,
    List<ScanResultEntry>? results,
    Set<int>? selectedIndices,
    int? Function()? editingIndex,
    int? saveTick,
    bool? hasLoggedSomething,
    bool? navigateToSummary,
    String? Function()? errorMessage,
  }) {
    return FoodScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      isSaving: isSaving ?? this.isSaving,
      results: results ?? this.results,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      editingIndex: editingIndex != null ? editingIndex() : this.editingIndex,
      saveTick: saveTick ?? this.saveTick,
      hasLoggedSomething: hasLoggedSomething ?? this.hasLoggedSomething,
      navigateToSummary: navigateToSummary ?? this.navigateToSummary,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  bool get hasResults => results.isNotEmpty;
  bool get hasSelection => selectedIndices.isNotEmpty;

  /// Topmost (lowest-index) checked row, or null if nothing checked.
  int? get topmostSelectedIndex {
    if (selectedIndices.isEmpty) return null;
    return selectedIndices.reduce((a, b) => a < b ? a : b);
  }

  /// Whether Log all can run: at least one checked row has an estimated
  /// gram amount. Rows without grams are left behind for manual editing.
  bool get canLogAll {
    return selectedIndices.any((i) {
      if (i >= results.length) return false;
      return results[i].scanResult.estimatedGrams != null;
    });
  }
}

/// A single scan result entry with selection state.
class ScanResultEntry {
  final ScanResult scanResult;
  final bool isSelected;

  ScanResultEntry({
    required this.scanResult,
    this.isSelected = false,
  });
}
