import 'package:flutter/material.dart';
import 'package:skinoura/database/data_ingredient/list_ingredient.dart';
import 'package:skinoura/models/ingredient_model.dart';

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
      appBar: AppBar(title: const Text("Skinoura")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search Ingredient",
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
                        "Comedogenicity (${selectedIngredient!.comedogenicity}/5)",
                      ),

                      const SizedBox(height: 8),

                      LinearProgressIndicator(
                        value: selectedIngredient!.comedogenicity / 5,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Irritation Risk (${selectedIngredient!.irritationRisk}/5)",
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
    );
  }
}
