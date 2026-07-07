import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinoura/models/question_model.dart';
import 'package:skinoura/database/data_ingredient/data_quiz.dart';

class DataQuizFirebase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengunggah data kuis lokal ke Firestore (Inisialisasi awal)
  static Future<void> uploadLocalQuizToFirestore() async {
    try {
      final WriteBatch batch = _firestore.batch();
      final CollectionReference quizCollection = _firestore.collection('quiz_questions');

      for (int i = 0; i < skinQuizQuestions.length; i++) {
        final Question question = skinQuizQuestions[i];
        final docRef = quizCollection.doc('q_${i + 1}');
        
        batch.set(docRef, {
          'id': i + 1,
          'questionText': question.questionText,
          'options': question.options.map((opt) => {
            'optionText': opt.optionText,
            'skinType': opt.skinType,
            'recommendedIngredients': opt.recommendedIngredients,
          }).toList(),
        });
      }

      await batch.commit();
      print("Berhasil mengunggah data kuis lokal ke Firestore.");
    } catch (e) {
      print("Gagal mengunggah data kuis ke Firestore: $e");
    }
  }

  // Fungsi untuk mengambil daftar pertanyaan kuis dari Firestore secara dinamis
  static Future<List<Question>> fetchQuizFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_questions')
          .orderBy('id')
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Jika data di Firestore masih kosong, unggah data lokal terlebih dahulu sebagai inisialisasi
        await uploadLocalQuizToFirestore();
        return skinQuizQuestions;
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final List<dynamic> optionsData = data['options'] ?? [];
        
        return Question(
          questionText: data['questionText'] ?? '',
          options: optionsData.map((opt) {
            final List<dynamic> ingredientsData = opt['recommendedIngredients'] ?? [];
            return AnswerOption(
              optionText: opt['optionText'] ?? '',
              skinType: opt['skinType'] ?? '',
              recommendedIngredients: List<String>.from(ingredientsData),
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      print("Gagal mengambil data kuis dari Firestore: $e. Menggunakan data lokal.");
      // Fallback otomatis menggunakan data lokal jika ada kegagalan koneksi
      return skinQuizQuestions;
    }
  }
}
