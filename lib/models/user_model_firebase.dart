import 'package:cloud_firestore/cloud_firestore.dart';

class UserModelFirebase {
  final String? uid;
  final String? nama;
  final String email;
  final String password;
  final DateTime? createdAt;

  UserModelFirebase({
    this.uid,
    this.nama,
    required this.email,
    required this.password,
    this.createdAt,
  });

  UserModelFirebase copyWith({
    String? uid,
    String? nama,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModelFirebase(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModelFirebase.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
      }
    }
    return UserModelFirebase(
      uid: json['uid'] as String?,
      nama: json['nama'] as String?,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) =>
      UserModelFirebase.fromJson(map);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'nama': nama,
      'email': email,
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  String toString() {
    return 'UserModelFirebase(uid: $uid, nama: $nama, email: $email, password: $password, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant UserModelFirebase other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.nama == nama &&
        other.email == email &&
        other.password == password &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        nama.hashCode ^
        email.hashCode ^
        password.hashCode ^
        createdAt.hashCode;
  }
}

