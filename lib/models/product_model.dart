class ProductModel {
  final String productName;
  final String image;
  final String category;
  final List<String> ingredients;
  final List<String> skinTypes;

  ProductModel({
    required this.productName,
    required this.image,
    required this.category,
    required this.ingredients,
    required this.skinTypes,
  });
}
