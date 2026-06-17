import 'package:flutter/material.dart';
import 'package:skinoura/database/data_ingredient/list_ingredient.dart';
// import 'package:skinoura/database/data_ingredient/list_produk.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/ingredient_model.dart';
// import 'package:skinoura/models/product_model.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  // String? selectedProduct;
  // String? selectedSkinType;
  // String? selectedCategory = "Semua";
  // final categories = [
  //   "Semua",
  //   "Face Wash",
  //   "Serum",
  //   "Moisturizer",
  //   "Sunscreen",
  // ];
  // List<ProductModel> get filteredProducts {
  //   return Productlist.where((product) {
  //     final matchCategory =
  //         selectedCategory == "Semua" || product.category == selectedCategory;

  //     final matchIngredient =
  //         selectedIngredient == null ||
  //         product.ingredients.contains(selectedIngredient);

  //     final matchSkinType =
  //         selectedSkinType == null ||
  //         product.skinTypes.contains(selectedSkinType);

  //     return matchCategory && matchIngredient && matchSkinType;
  //   }).toList();
  // }

  final TextEditingController searchController = TextEditingController();

  Ingredient? selectedIngredient;

  void analyzeIngredient() {
    try {
      final ingredient = ingredients.firstWhere(
        (item) =>
            item.name.toLowerCase() == searchController.text.toLowerCase(),
      );

      setState(() {
        selectedIngredient = ingredient;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingredient not found")));
    }
  }

  Color getSafetyColor(String safety) {
    switch (safety) {
      case "Safe":
        return Colors.green;

      case "Moderate":
        return Colors.orange;

      case "Use Carefully":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (PreferencesHandler.skinType.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Disarankan untuk anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Berdasarkan kulit anda yang bertipe ${PreferencesHandler.skinType}",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PreferencesHandler.recommendedIngredients
                            .map(
                              (ingredient) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4EF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ingredient,
                                  style: const TextStyle(
                                    color: Color(0xFF436155),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari formula",
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: analyzeIngredient,
                    child: const Text("Analyze"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              if (selectedIngredient != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedIngredient!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getSafetyColor(
                                  selectedIngredient!.safety,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                selectedIngredient!.safety,
                                style: TextStyle(
                                  color: getSafetyColor(
                                    selectedIngredient!.safety,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(selectedIngredient!.description),

                        const SizedBox(height: 20),

                        Text(
                          "Menyebabkan Komedo (${selectedIngredient!.comedogenicity}/5)",
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: selectedIngredient!.comedogenicity / 5,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Menyebabkan Iritasi (${selectedIngredient!.irritationRisk}/5)",
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: selectedIngredient!.irritationRisk / 5,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Clinical Evidence: ${selectedIngredient!.evidence}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
