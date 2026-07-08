import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinoura/models/user_model_firebase.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan info user yang sedang login saat ini
  User? get currentFirebaseUser => _auth.currentUser;

  // Registrasi pengguna baru menggunakan Email & Password
  Future<UserModelFirebase?> signUpWithEmailAndPassword({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Buat user di Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // 2. Buat model data pengguna
        UserModelFirebase newUser = UserModelFirebase(
          uid: user.uid,
          nama: nama,
          email: email,
          createdAt: DateTime.now(),
        );

        // 3. Simpan data pengguna ke Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException di signUp: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error tidak terduga di signUp: $e');
      throw Exception('Terjadi kesalahan saat pendaftaran: $e');
    }
    return null;
  }

  // Login pengguna menggunakan Email & Password
  Future<UserModelFirebase?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign In ke Firebase Auth
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // 2. Ambil data dari Firestore
        return await getUserProfile(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException di signIn: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error tidak terduga di signIn: $e');
      throw Exception('Terjadi kesalahan saat masuk: $e');
    }
    return null;
  }

  // Mengambil profile data pengguna dari Firestore berdasarkan UID
  Future<UserModelFirebase?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModelFirebase.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error mengambil profil user ($uid): $e');
    }
    return null;
  }

  // Memperbarui data profil pengguna di Firestore
  Future<bool> updateUserProfile(UserModelFirebase user) async {
    try {
      if (user.uid == null) return false;
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      log('Error memperbarui profil user (${user.uid}): $e');
      return false;
    }
  }

  // Sign Out / Keluar
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error saat signOut: $e');
      rethrow;
    }
  }

  // Mendapatkan profil user yang sedang login saat ini (jika ada)
  Future<UserModelFirebase?> getCurrentUserModel() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.uid);
    }
    return null;
  }
}
