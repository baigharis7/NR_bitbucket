class FoodScannerAction {}

/// Set the meal type every save from this scanner session should target.
class InitializeMealTypeAction extends FoodScannerAction {
  final int mealType;

  InitializeMealTypeAction({required this.mealType});
}

/// Triggered when camera detects food candidates (visual recognition).
class OnVisualFoodDetectedAction extends FoodScannerAction {
  /// List of detected food names with estimated grams and kcal.
  final List<DetectedFoodCandidate> candidates;

  OnVisualFoodDetectedAction({required this.candidates});
}

/// Triggered when camera detects a barcode.
class OnBarcodeDetectedAction extends FoodScannerAction {
  final String barcode;

  OnBarcodeDetectedAction({required this.barcode});
}

/// User toggles the checkbox on a result row.
class ToggleFoodSelectionAction extends FoodScannerAction {
  final int index;

  ToggleFoodSelectionAction({required this.index});
}

/// Log the topmost checked row. If it has a gram estimate it saves a
/// FoodEvent directly; otherwise it falls into the edit flow.
class LogTopmostAction extends FoodScannerAction {}

/// Log every checked row that has a gram estimate as its own FoodEvent.
/// Rows without grams remain in the list.
class LogAllAction extends FoodScannerAction {}

/// Start the edit flow for the topmost checked row.
class EditTopmostAction extends FoodScannerAction {}

/// Notify the bloc that the edit screen finished successfully and the
/// given row is now logged. Removes it from the list.
class EditCompletedAction extends FoodScannerAction {
  final int index;

  EditCompletedAction({required this.index});
}

/// Notify the bloc that the user exited the edit screen without saving.
/// Stops an in-progress Log all batch so it doesn't auto-resume on a
/// later, unrelated edit.
class EditCancelledAction extends FoodScannerAction {}

/// Clears [FoodScannerState.editingIndex] — used by the screen listener
/// once it has consumed the signal (either by pushing the edit screen
/// or by reacting to a back-button return).
class ClearEditingAction extends FoodScannerAction {}

/// Clears [FoodScannerState.navigateToSummary] after the screen pops.
class ClearNavigateToSummaryAction extends FoodScannerAction {}

/// User taps the capture button — triggers visual identification.
class CapturePhotoAction extends FoodScannerAction {
  /// JPEG image bytes from the camera.
  final List<int> imageBytes;

  CapturePhotoAction({required this.imageBytes});
}

/// Reset scanner to initial state (clear results).
class ResetScannerAction extends FoodScannerAction {}

/// Lightweight data class for a detected food candidate from the camera.
class DetectedFoodCandidate {
  final String name;
  final String? passioFoodId;
  final double? estimatedGrams;
  final double? estimatedKcal;

  /// Detection confidence from the provider (0.0–1.0).
  final double? confidence;

  /// LogMeal dish ID — used to fetch ingredients for unmatched dishes.
  final int? logmealDishId;

  /// Per-100g nutrient map (already mapped to our Params keys).
  final Map<String, double>? nutrientsPer100g;

  DetectedFoodCandidate({
    required this.name,
    this.passioFoodId,
    this.estimatedGrams,
    this.estimatedKcal,
    this.confidence,
    this.logmealDishId,
    this.nutrientsPer100g,
  });
}
