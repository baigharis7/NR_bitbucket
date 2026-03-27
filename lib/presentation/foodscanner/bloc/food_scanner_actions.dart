class FoodScannerAction {}

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

/// User selects/deselects a food from the results list.
class ToggleFoodSelectionAction extends FoodScannerAction {
  final int index;

  ToggleFoodSelectionAction({required this.index});
}

/// User taps "Log selected" — log all selected foods with scan defaults.
class LogSelectedFoodsAction extends FoodScannerAction {}

/// User taps "Edit" / "Continue" — start editing the next selected food.
class EditNextSelectedFoodAction extends FoodScannerAction {}

/// A food has been edited and saved via AddFoodEventScreen.
/// Removes it from the pending list.
class FoodEditedAction extends FoodScannerAction {
  final int index;

  FoodEditedAction({required this.index});
}

/// User taps the capture button — triggers Claude Vision identification.
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
