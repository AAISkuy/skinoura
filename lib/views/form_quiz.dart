import 'package:flutter/material.dart';
import 'package:skinoura/database/data_ingredient/data_quiz.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/question_model.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // 1. Data Pertanyaan Dummy
  final List<Question> _questions = skinQuizQuestions;

  // 2. State Management internal Quiz
  int _currentIndex = 0; // Menandakan pertanyaan ke-berapa yang aktif
  final List<AnswerOption> _selectedAnswers =
      []; // Menyimpan semua jawaban pilihan user

  // 3. Fungsi Logika Hitung Hasil & Simpan
  Future<void> _hitungHasilQuiz() async {
    Map<String, int> scoreSkinType = {
      "Oily": 0,
      "Dry": 0,
      "Combination": 0,
      "Sensitive": 0,
    };

    Set<String> collectedIngredients = {};

    for (var jawaban in _selectedAnswers) {
      if (scoreSkinType.containsKey(jawaban.skinType)) {
        scoreSkinType[jawaban.skinType] = scoreSkinType[jawaban.skinType]! + 1;
      }
      if (jawaban.skinType == "Sensitive") {
        scoreSkinType["Sensitive"] = scoreSkinType["Sensitive"]! + 2;
      }
      collectedIngredients.addAll(jawaban.recommendedIngredients);
    }

    // Cari tipe kulit skor tertinggi
    String tipeKulitFinal = scoreSkinType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    List<String> listIngredients = collectedIngredients.toList();
    await PreferencesHandler.saveSkinType(tipeKulitFinal);

    await PreferencesHandler.saveRecommendedIngredients(listIngredients);

    // --- DI SINI PROSES SIMPAN KE PREFERENCES ---
    // PreferencesHandler.namaSkintype = tipeKulitFinal;
    // PreferencesHandler.saveIngredients(jsonEncode(listIngredients));

    // Tampilin dialog berhasil sebelum balik ke halaman utama/profile
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Selesai!"),
        content: Text(
          "Tipe kulitmu adalah $tipeKulitFinal.\nBahan yang cocok: ${listIngredients.join(', ')}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Balik ke halaman Profile
            },
            child: const Text("Lihat Profil"),
          ),
        ],
      ),
    );
  }

  // 4. Fungsi ketika opsi jawaban diklik
  void _nextQuestion(AnswerOption option) {
    _selectedAnswers.add(option);

    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++; // Pindah ke pertanyaan berikutnya
      } else {
        _hitungHasilQuiz(); // Kalau sudah pertanyaan terakhir, hitung hasil
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    // Menghitung persentase progress untuk LinearProgressIndicator (0.0 sampai 1.0)
    double progressPercent = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
      appBar: AppBar(
        title: const Text(
          'Skin Type Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROGRESS BAR & INDIKATOR ANGKA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pertanyaan ${_currentIndex + 1} dari ${_questions.length}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "${(progressPercent * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF436155),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.black,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF436155),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 40),

            // --- TEKS PERTANYAAN ---
            Text(
              currentQuestion.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // --- DAFTAR PILIHAN JAWABAN (Dinamis memakai Map) ---
            Expanded(
              child: ListView(
                children: currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: OutlinedButton(
                      onPressed: () => _nextQuestion(option),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          option.optionText,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
