import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';

class FoodScannerState {
  /// Whether the scanner is processing a detection.
  final bool isProcessing;

  /// Results from the most recent scan.
  /// Each entry is a detected food with match info.
  final List<ScanResultEntry> results;

  /// Which results the user has selected (by index).
  final Set<int> selectedIndices;

  /// Index of the food currently being edited (sequential edit flow).
  /// Null when not in edit mode.
  final int? editingIndex;

  /// Error message to display, if any.
  final String? errorMessage;

  /// Foods that have been fully edited/confirmed (removed from results).
  final List<ScanResultEntry> editedFoods;

  const FoodScannerState({
    this.isProcessing = false,
    this.results = const [],
    this.selectedIndices = const {},
    this.editingIndex,
    this.errorMessage,
    this.editedFoods = const [],
  });

  FoodScannerState copyWith({
    bool? isProcessing,
    List<ScanResultEntry>? results,
    Set<int>? selectedIndices,
    int? Function()? editingIndex,
    String? Function()? errorMessage,
    List<ScanResultEntry>? editedFoods,
  }) {
    return FoodScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      results: results ?? this.results,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      editingIndex: editingIndex != null ? editingIndex() : this.editingIndex,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      editedFoods: editedFoods ?? this.editedFoods,
    );
  }

  bool get hasResults => results.isNotEmpty;
  bool get hasSelection => selectedIndices.isNotEmpty;
  bool get isEditing => editingIndex != null;

  /// Whether we're in mid-edit flow (some foods already edited, more remain).
  bool get hasMoreToEdit {
    final remaining = selectedIndices
        .where((i) => !editedFoods.any((e) => e == results[i]))
        .toList();
    return remaining.length > 1;
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
