import 'package:flutter/material.dart';
import 'package:skinoura/views/form_quiz.dart';
import 'package:skinoura/widgets/indicator_card.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  final String userName;
  const Homepage({super.key, required this.userName});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<RitualModel> rituals = [];
  double completionRate = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayRituals();
  }

  Future<void> loadTodayRituals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final email = PreferencesHandler.email;
      if (email.isNotEmpty) {
        final allRituals = await DBHelper().getRitualsByEmail(email);
        final String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
        
        // Filter out soft-deleted rituals
        final filteredData = allRituals.where((ritual) {
          if (ritual.createdAt == null && ritual.deletedAt == null) return true;
          final bool isCreated =
              ritual.createdAt == null || ritual.createdAt!.compareTo(dateKey) <= 0;
          final bool isNotDeleted =
              ritual.deletedAt == null || dateKey.compareTo(ritual.deletedAt!) < 0;
          return isCreated && isNotDeleted;
        }).toList();

        // Assign completion status based on SharedPreferences
        for (var ritual in filteredData) {
          final String key = "${dateKey}_${ritual.id}";
          ritual.isDone = PreferencesHandler.getStepStatus(key);
        }

        int total = filteredData.length;
        int done = filteredData.where((e) => e.isDone).length;
        
        if (mounted) {
          setState(() {
            rituals = filteredData;
            completionRate = total == 0 ? 0.0 : (done / total);
          });
        }
      }
    } catch (e) {
      print("Error loading today's rituals: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSkinConditionSummaryText() {
    if (rituals.isEmpty) {
      return "Belum ada skincare protocol yang ditambahkan hari ini.";
    }
    if (completionRate == 1.0) {
      return "Luar biasa! Semua skincare protocol hari ini telah digunakan.";
    }
    if (completionRate >= 0.5) {
      return "Bagus! Sebagian besar skincare protocol hari ini sudah digunakan.";
    }
    if (completionRate > 0.0) {
      return "Yuk, selesaikan sisa skincare protocol Anda agar kulit tetap sehat.";
    }
    return "Skincare protocol hari ini belum ada yang digunakan.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      body: RefreshIndicator(
        color: const Color(0xFF436155),
        onRefresh: loadTodayRituals,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.userName}.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rituals.isEmpty
                            ? 'Mulai atur skincare protocol kamu hari ini.'
                            : completionRate == 1.0
                                ? 'Hebat! Rutinitas skincare kamu hari ini selesai.'
                                : 'Kulit kamu terlihat sehat hari ini.',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
              ),
  
              const SizedBox(height: 15),
  
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
                        const Text(
                          'Rangkuman \nkondisi kulit',
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
                    Text(
                      _getSkinConditionSummaryText(),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
  
                    const SizedBox(height: 20),
  
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF436155)),
                              ),
                            ),
                          )
                        : GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            children: [
                              IndicatorCard(
                                icon: Icons.opacity,
                                value: '${(40 + (completionRate * 60).round())}%',
                                title: 'Hydration',
                              ),
                              IndicatorCard(
                                icon: Icons.shield_outlined,
                                value: completionRate >= 0.75
                                    ? 'Strong'
                                    : completionRate >= 0.5
                                        ? 'Good'
                                        : completionRate >= 0.25
                                            ? 'Average'
                                            : 'Weak',
                                title: 'Barrier',
                              ),
                              IndicatorCard(
                                icon: Icons.opacity,
                                value: completionRate >= 0.75
                                    ? 'Low'
                                    : completionRate >= 0.3
                                        ? 'Moderate'
                                        : 'High',
                                title: 'Sensitivity',
                              ),
                              IndicatorCard(
                                icon: Icons.opacity,
                                value: completionRate >= 0.75
                                    ? 'Balanced'
                                    : completionRate >= 0.3
                                        ? 'Normal'
                                        : 'Unbalanced',
                                title: 'Sebum',
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
  
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF436155),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Skin Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ayo cari tahu jenis kulit kamu",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
  
                    const SizedBox(height: 20),
  
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizPage(),
                          ),
                        ).then((_) {
                          loadTodayRituals();
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
  
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
