import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinoura/database/data_ingredient/data_quiz.dart';
import 'package:skinoura/database/preferences_handler.dart';
import 'package:skinoura/models/question_model.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Data Pertanyaan Dummy
  final List<Question> _questions = skinQuizQuestions;

  // State Management internal Quiz
  int _currentIndex = 0; // Menandakan pertanyaan ke-berapa yang aktif
  final List<AnswerOption> _selectedAnswers =
      []; // Menyimpan semua jawaban pilihan user

  // Fungsi Logika Hitung Hasil & Simpan
  Future<void> _hitungHasilQuiz() async {
    Map<String, int> scoreSkinType = {
      "Berminyak": 0,
      "Kering": 0,
      "Kombinasi": 0,
      "Sensitif": 0,
      "Normal": 0,
    };

    Set<String> collectedIngredients = {};

    for (var jawaban in _selectedAnswers) {
      // Petakan skinType bahasa Inggris ke bahasa Indonesia agar sesuai dengan map scoreSkinType
      String skinTypeIndo = "";
      switch (jawaban.skinType) {
        case "Oily":
          skinTypeIndo = "Berminyak";
          break;
        case "Dry":
          skinTypeIndo = "Kering";
          break;
        case "Combination":
          skinTypeIndo = "Kombinasi";
          break;
        case "Sensitive":
        case "Sensitif":
          skinTypeIndo = "Sensitif";
          break;
        case "Normal":
          skinTypeIndo = "Normal";
          break;
        default:
          skinTypeIndo = jawaban.skinType;
      }

      if (scoreSkinType.containsKey(skinTypeIndo)) {
        scoreSkinType[skinTypeIndo] = scoreSkinType[skinTypeIndo]! + 1;
      }
      if (skinTypeIndo == "Sensitif") {
        scoreSkinType["Sensitif"] = scoreSkinType["Sensitif"]! + 2;
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

    // Unggah ke Firestore (tanpa await agar respons dialog instan)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'skinType': tipeKulitFinal,
            'recommendedIngredients': listIngredients,
          })
          .catchError((e) {
            print("Error updating skin type in Firestore: $e");
          });
    }

    // Tampilin dialog berhasil sebelum balik ke halaman utama/profile
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Selesai!"),
        content: Text(
          "Tipe kulitmu adalah $tipeKulitFinal.\nBahan yang direkomendasi untuk tipe kulit anda akan tampil di discovery",
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

  // Fungsi ketika opsi jawaban diklik
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
    // Menghitung persentase progress untuk LinearProgressIndicator
    double progressPercent = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skin Type Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROGRESS BAR dan INDIKATOR ANGKA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pertanyaan ${_currentIndex + 1} dari ${_questions.length}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
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
                backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
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
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // --- DAFTAR PILIHAN JAWABAN (Map) ---
            Expanded(
              child: ListView(
                children: currentQuestion.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: OutlinedButton(
                      onPressed: () => _nextQuestion(option),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: Theme.of(context).cardColor,
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
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
