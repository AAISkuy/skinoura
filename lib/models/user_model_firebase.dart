import 'package:cloud_firestore/cloud_firestore.dart';

class UserModelFirebase {
  final String? uid;
  final String? nama;
  final String email;
  final DateTime? createdAt;
  final String? profilePicture;
  final String? skinType;
  final List<String>? recommendedIngredients;
  final bool? notificationEnabled;
  final int? notificationHour;
  final int? notificationMinute;

  UserModelFirebase({
    this.uid,
    this.nama,
    required this.email,
    this.createdAt,
    this.profilePicture,
    this.skinType,
    this.recommendedIngredients,
    this.notificationEnabled,
    this.notificationHour,
    this.notificationMinute,
  });

  UserModelFirebase copyWith({
    String? uid,
    String? nama,
    String? email,
    DateTime? createdAt,
    String? profilePicture,
    String? skinType,
    List<String>? recommendedIngredients,
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return UserModelFirebase(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      profilePicture: profilePicture ?? this.profilePicture,
      skinType: skinType ?? this.skinType,
      recommendedIngredients: recommendedIngredients ?? this.recommendedIngredients,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
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

    final List<dynamic>? recIngredientsRaw = json['recommendedIngredients'] as List<dynamic>?;
    final List<String>? recIngredients = recIngredientsRaw != null
        ? List<String>.from(recIngredientsRaw)
        : null;

    return UserModelFirebase(
      uid: json['uid'] as String?,
      nama: json['nama'] as String?,
      email: json['email'] as String? ?? '',
      createdAt: parsedCreatedAt,
      profilePicture: json['profilePicture'] as String?,
      skinType: json['skinType'] as String?,
      recommendedIngredients: recIngredients,
      notificationEnabled: json['notificationEnabled'] as bool?,
      notificationHour: json['notificationHour'] as int?,
      notificationMinute: json['notificationMinute'] as int?,
    );
  }

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) =>
      UserModelFirebase.fromJson(map);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'nama': nama,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'profilePicture': profilePicture,
      'skinType': skinType,
      'recommendedIngredients': recommendedIngredients,
      'notificationEnabled': notificationEnabled,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  String toString() {
    return 'UserModelFirebase(uid: $uid, nama: $nama, email: $email, createdAt: $createdAt, profilePicture: $profilePicture, skinType: $skinType, recommendedIngredients: $recommendedIngredients, notificationEnabled: $notificationEnabled, notificationHour: $notificationHour, notificationMinute: $notificationMinute)';
  }

  @override
  bool operator ==(covariant UserModelFirebase other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.nama == nama &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.profilePicture == profilePicture &&
        other.skinType == skinType &&
        other.recommendedIngredients == recommendedIngredients &&
        other.notificationEnabled == notificationEnabled &&
        other.notificationHour == notificationHour &&
        other.notificationMinute == notificationMinute;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        nama.hashCode ^
        email.hashCode ^
        createdAt.hashCode ^
        profilePicture.hashCode ^
        skinType.hashCode ^
        recommendedIngredients.hashCode ^
        notificationEnabled.hashCode ^
        notificationHour.hashCode ^
        notificationMinute.hashCode;
  }
}
