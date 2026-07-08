import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skinoura/models/ritual_model.dart';
import 'package:skinoura/models/user_model_firebase.dart';
import 'package:skinoura/database/database_helper.dart';
import 'package:skinoura/database/preferences_handler.dart';

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

  // Sinkronisasi data menyeluruh dari Firebase ke lokal (dan sebaliknya)
  Future<void> syncData() async {
    final email = PreferencesHandler.email;
    if (email.isEmpty) return;

    try {
      // 1. Pastikan user terautentikasi ke Firebase Auth
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        final password = PreferencesHandler.password;
        if (password.isNotEmpty) {
          try {
            final credential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);
            currentUser = credential.user;
          } catch (e) {
            log("Auto login ke Firebase Auth gagal: $e");
          }
        }
      }

      if (currentUser == null) {
        log("Sinkronisasi dibatalkan: Pengguna belum terautentikasi.");
        return;
      }

      // 2. Sinkronisasi data profil user dari Firestore ke local Preferences
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          // Sync skinType
          final String? remoteSkinType = data['skinType'] as String?;
          if (remoteSkinType != null && remoteSkinType.isNotEmpty) {
            await PreferencesHandler.saveSkinType(remoteSkinType);
          }
          
          // Sync recommended ingredients
          final List<dynamic>? remoteIngredients = data['recommendedIngredients'] as List<dynamic>?;
          if (remoteIngredients != null) {
            await PreferencesHandler.saveRecommendedIngredients(
              remoteIngredients.map((e) => e.toString()).toList(),
            );
          }

          // Sync profile picture
          final String? remoteProfilePic = data['profilePicture'] as String?;
          if (remoteProfilePic != null && remoteProfilePic.isNotEmpty) {
            await PreferencesHandler.saveProfilePicture(remoteProfilePic);
          }

          // Sync notification settings
          final bool? remoteNotifEnabled = data['notificationEnabled'] as bool?;
          if (remoteNotifEnabled != null) {
            await PreferencesHandler.setNotificationEnabled(remoteNotifEnabled);
            final int hour = data['notificationHour'] as int? ?? 8;
            final int minute = data['notificationMinute'] as int? ?? 0;
            await PreferencesHandler.setNotificationTime(hour, minute);
          }
        }
      }

      // 3. Sinkronisasi daftar ritual (SQLite <=> Firestore)
      final localRituals = await DBHelper().getRitualsByEmail(email);
      final remoteRituals = await getRitualsByEmail(email);

      final localMap = {for (var r in localRituals) r.id: r};
      final remoteMap = {for (var r in remoteRituals) r.id: r};

      // Sync dari remote ke lokal (SQLite)
      for (var remoteRitual in remoteRituals) {
        final localRitual = localMap[remoteRitual.id];
        if (localRitual == null) {
          await DBHelper().insertRitual(remoteRitual);
        } else {
          // Jika ada perbedaan isi, perbarui data lokal
          if (localRitual.title != remoteRitual.title ||
              localRitual.subtitle != remoteRitual.subtitle ||
              localRitual.createdAt != remoteRitual.createdAt ||
              localRitual.deletedAt != remoteRitual.deletedAt) {
            await DBHelper().updateRitual(remoteRitual);
          }
        }
      }

      // Sync dari lokal ke remote (Firestore)
      for (var localRitual in localRituals) {
        if (!remoteMap.containsKey(localRitual.id)) {
          await insertRitual(localRitual);
        }
      }

      // 4. Sinkronisasi checklist status harian ke SharedPreferences
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('step_statuses')
          .get();

      for (var doc in snapshot.docs) {
        final String key = doc.id;
        final bool isDone = doc.data()['isDone'] ?? false;
        await PreferencesHandler.saveStepStatus(key, isDone);
      }
    } catch (e) {
      log("Error syncing with Firebase: $e");
    }
  }
}
