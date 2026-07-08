import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:skinoura/models/user_model_firebase.dart';

class FirebaseDBHelper {
  static final FirebaseDBHelper _instance = FirebaseDBHelper._internal();

  factory FirebaseDBHelper() => _instance;

  FirebaseDBHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Menyimpan data registrasi user ke Cloud Firestore
  Future<bool> registerUser(UserModelFirebase pengguna) async {
    try {
      final docId = pengguna.uid ?? _firestore.collection('users').doc().id;
      final userToSave = pengguna.uid == null ? pengguna.copyWith(uid: docId) : pengguna;
      
      await _firestore.collection('users').doc(docId).set(userToSave.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      log('FirebaseDBHelper registerUser error: $e');
      return false;
    }
  }

  // Verifikasi login user berdasarkan email & password di Cloud Firestore
  Future<UserModelFirebase?> loginUser(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModelFirebase.fromMap(querySnapshot.docs.first.data());
      }
    } catch (e) {
      log('FirebaseDBHelper loginUser error: $e');
    }
    return null;
  }

  // Mengambil daftar semua user dari Cloud Firestore
  Future<List<UserModelFirebase>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModelFirebase.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('FirebaseDBHelper getAllUsers error: $e');
      return [];
    }
  }

  // Menghapus user berdasarkan UID
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      log('FirebaseDBHelper deleteUser error: $e');
    }
  }

  // Memperbarui data user
  Future<bool> updateUser(UserModelFirebase pengguna) async {
    try {
      if (pengguna.uid == null) return false;
      await _firestore
          .collection('users')
          .doc(pengguna.uid)
          .set(pengguna.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      log('FirebaseDBHelper updateUser error: $e');
      return false;
    }
  }

  // ==================== RITUAL OPERATIONS ====================

  // Menambah ritual baru ke Cloud Firestore
  Future<bool> insertRitual(RitualModel ritual) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      // Jika id ritual kosong, generate unik berbasis timestamp int
      int id = ritual.id ?? DateTime.now().millisecondsSinceEpoch;
      ritual.id = id;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(id.toString())
          .set(ritual.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      log('FirebaseDBHelper insertRitual error: $e');
      return false;
    }
  }

  // Mengambil semua ritual milik user tertentu berdasarkan email
  Future<List<RitualModel>> getRitualsByEmail(String email) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .get();

      return querySnapshot.docs.map((doc) {
        final map = doc.data();
        if (map['id'] == null) {
          map['id'] = int.tryParse(doc.id);
        }
        return RitualModel.fromMap(map);
      }).toList();
    } catch (e) {
      log('FirebaseDBHelper getRitualsByEmail error: $e');
      return [];
    }
  }

  // Memperbarui status selesai/tidak dari ritual (isDone)
  Future<bool> updateRitualStatus(int id, bool isDone) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(id.toString())
          .update({'isDone': isDone ? 1 : 0});
      return true;
    } catch (e) {
      log('FirebaseDBHelper updateRitualStatus error: $e');
      return false;
    }
  }

  // Memperbarui isi data ritual
  Future<bool> updateRitual(RitualModel ritual) async {
    try {
      if (ritual.id == null) return false;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(ritual.id.toString())
          .set(ritual.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      log('FirebaseDBHelper updateRitual error: $e');
      return false;
    }
  }

  // Menghapus ritual berdasarkan id integer
  Future<bool> deleteRitual(int id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(id.toString())
          .delete();
      return true;
    } catch (e) {
      log('FirebaseDBHelper deleteRitual error: $e');
      return false;
    }
  }
}
