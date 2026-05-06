/// Parsed response from OpenFoodFacts product API.
class OpenFoodFactsProduct {
  final String barcode;
  final String? productName;
  final String? brands;
  final Map<String, dynamic> nutriments;
  final String? servingSize;
  final String? imageUrl;
  final List<String> categoriesTags;

  OpenFoodFactsProduct({
    required this.barcode,
    this.productName,
    this.brands,
    required this.nutriments,
    this.servingSize,
    this.imageUrl,
    this.categoriesTags = const [],
  });

  factory OpenFoodFactsProduct.fromJson(
      String barcode, Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final rawTags = product['categories_tags'];
    final tags = rawTags is List
        ? rawTags.whereType<String>().toList(growable: false)
        : const <String>[];
    return OpenFoodFactsProduct(
      barcode: barcode,
      productName: product['product_name'] as String?,
      brands: product['brands'] as String?,
      nutriments:
          product['nutriments'] as Map<String, dynamic>? ?? {},
      servingSize: product['serving_size'] as String?,
      imageUrl: product['image_front_url'] as String?,
      categoriesTags: tags,
    );
  }

  bool get isFound => productName != null && productName!.isNotEmpty;

  /// True if OFF tags this product as a beverage.
  bool get isBeverage =>
      categoriesTags.any((t) => t == 'en:beverages' || t.startsWith('en:beverages-'));
}
