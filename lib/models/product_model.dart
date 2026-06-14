class ProductModel {
  final String productName;
  final String imagePath;
  final String category;
  final List<String> ingredients;
  final List<String> skinTypes;

  ProductModel({
    required this.productName,
    required this.imagePath,
    required this.category,
    required this.ingredients,
    required this.skinTypes,
  });
}
