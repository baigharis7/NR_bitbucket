/// Parsed response from OpenFoodFacts product API.
class OpenFoodFactsProduct {
  final String barcode;
  final String? productName;
  final String? brands;
  final Map<String, dynamic> nutriments;
  final String? servingSize;
  final String? imageUrl;

  OpenFoodFactsProduct({
    required this.barcode,
    this.productName,
    this.brands,
    required this.nutriments,
    this.servingSize,
    this.imageUrl,
  });

  factory OpenFoodFactsProduct.fromJson(
      String barcode, Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return OpenFoodFactsProduct(
      barcode: barcode,
      productName: product['product_name'] as String?,
      brands: product['brands'] as String?,
      nutriments:
          product['nutriments'] as Map<String, dynamic>? ?? {},
      servingSize: product['serving_size'] as String?,
      imageUrl: product['image_front_url'] as String?,
    );
  }

  bool get isFound => productName != null && productName!.isNotEmpty;
}
