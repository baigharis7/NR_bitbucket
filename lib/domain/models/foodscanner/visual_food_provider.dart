import 'dart:typed_data';

/// Interface for visual food recognition providers.
///
/// Implementations include [ClaudeVisionProvider] and [LogMealProvider].
/// This abstraction allows swapping providers without changing the BLoC.
abstract class VisualFoodProvider {
  /// Identify foods in the given image bytes.
  ///
  /// Returns a list of detected foods with names and estimated portions.
  /// Returns empty list on error or if no food is detected.
  Future<List<VisualFoodResult>> identifyFoods(Uint8List imageBytes);
}

/// A food detected by a visual recognition provider.
class VisualFoodResult {
  final String name;
  final double? estimatedGrams;
  final double? estimatedKcal;

  VisualFoodResult({
    required this.name,
    this.estimatedGrams,
    this.estimatedKcal,
  });
}
