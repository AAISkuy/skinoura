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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingredient tidak ditemukan")),
      );
    }
  }

  void selectRecommendedIngredient(String name) {
    try {
      final ingredient = ingredients.firstWhere(
        (item) => item.name.toLowerCase() == name.toLowerCase(),
      );

      setState(() {
        searchController.text = ingredient.name;
        selectedIngredient = ingredient;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Detail untuk $name tidak ditemukan")),
      );
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.02),
                    ),
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
                              (ingredient) => GestureDetector(
                                onTap: () =>
                                    selectRecommendedIngredient(ingredient),
                                  child: Builder(
                                    builder: (context) {
                                      final isDark = Theme.of(context).brightness == Brightness.dark;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF313F3B) : const Color(0xFFEAF4EF),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF7C9A92).withOpacity(0.3)
                                                : const Color(0xFF436155).withOpacity(0.15),
                                          ),
                                        ),
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(
                                            color: isDark ? const Color(0xFF7C9A92) : const Color(0xFF436155),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Analyze"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              if (selectedIngredient != null)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.02),
                    ),
                  ),
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
                                ).withValues(alpha: 0.2),
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
                          backgroundColor: Colors.red.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Menyebabkan Iritasi (${selectedIngredient!.irritationRisk}/5)",
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: selectedIngredient!.irritationRisk / 5,
                          backgroundColor: Colors.red.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
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
