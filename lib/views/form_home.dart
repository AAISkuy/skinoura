import 'package:flutter/material.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/views/form_quiz.dart';
import 'package:skinoura/widgets/indicator_card.dart';

class Homepage extends StatefulWidget {
  // final VoidCallback? onStartRoutineTap;
  // final VoidCallback? onSkinQuizTap;
  // final VoidCallback? onRecommendationTap;
  // final VoidCallback? onRoutineScheduleTap;
  // final VoidCallback? onIngredientCheckerTap;
  const Homepage({
    super.key,
    // this.onStartRoutineTap,
    // this.onIngredientCheckerTap,
    // this.onRecommendationTap,
    // this.onRoutineScheduleTap,
    // this.onSkinQuizTap,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${PreferencesHandler.nama}.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kulit kamu terlihat sehat hari ini.',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Skin Condition\nSummary',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2ECE9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Update Terbaru',
                          style: TextStyle(
                            color: Color(0xff436155),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Overall hydration and barrier strength are optimal.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: const [
                      IndicatorCard(
                        icon: Icons.opacity,
                        value: '78%',
                        title: 'Hydration',
                      ),
                      IndicatorCard(
                        icon: Icons.shield_outlined,
                        value: 'Good',
                        title: 'Barrier',
                      ),
                      IndicatorCard(
                        icon: Icons.opacity,
                        value: 'Low',
                        title: 'Sensitivity',
                      ),
                      IndicatorCard(
                        icon: Icons.opacity,
                        value: 'Balanced',
                        title: 'Sebum',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF436155),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skin Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ayo cari tahu jenis kulit kamu",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizPage(),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF436155),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Start Quiz",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
