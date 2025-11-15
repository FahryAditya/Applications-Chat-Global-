// file: user_model.dart

import 'dart:convert'; // Diperlukan untuk encoding/decoding JSON jika Anda menggunakannya di luar toJson/fromJson

/// Sebuah class model yang merepresentasikan data user.
class UserModel {
  // --- Fields ---
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bio;
  final String? role; // misal: 'user', 'admin'
  final Map<String, dynamic>? extra; // Data tambahan opsional

  // --- 1. Constructor Lengkap + Default Value ---
  /// Constructor lengkap dengan default value untuk fields tertentu.
  const UserModel({
    required this.id,
    this.name = '', // Default value
    required this.email,
    this.photoUrl,
    this.phone,
    this.isOnline = false, // Default value
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.role = 'user', // Default value
    this.extra,
  });

  // --- 5. UserModel.empty() ---
  /// Factory constructor untuk membuat instance UserModel kosong/default.
  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      id: '',
      name: 'Guest User',
      email: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // --- 2. fromJson(Map<String, dynamic> json) ---
  /// Membuat instance [UserModel] dari Map (JSON).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'user',
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  // --- 3. toJson() ---
  /// Mengubah instance [UserModel] menjadi Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bio': bio,
      'role': role,
      'extra': extra,
    };
  }

  // --- 4. copyWith() ---
  /// Membuat salinan [UserModel] dengan perubahan pada fields tertentu.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    String? role,
    Map<String, dynamic>? extra,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      extra: extra ?? this.extra,
    );
  }

  // --- 6. bool isComplete() ---
  /// Mengecek apakah profile user dianggap sudah lengkap (misalnya, nama dan email tidak kosong).
  bool isComplete() {
    // Definisi "lengkap" bisa disesuaikan. Di sini, kita cek id, name, dan email.
    return id.isNotEmpty && name.isNotEmpty && email.isNotEmpty;
  }

  // --- 7. String displayName() ---
  /// Mengembalikan nama user, dengan fallback ke email jika nama kosong.
  String displayName() {
    return name.isNotEmpty ? name : email;
  }

  // --- 8. UserModel updateOnline(bool value) ---
  /// Membuat salinan model baru dengan status online yang diperbarui.
  UserModel updateOnline(bool value) {
    return copyWith(isOnline: value, updatedAt: DateTime.now());
  }

  // --- 9. UserModel updatePhoto(String url) ---
  /// Membuat salinan model baru dengan URL foto yang diperbarui.
  UserModel updatePhoto(String url) {
    return copyWith(photoUrl: url, updatedAt: DateTime.now());
  }

  // --- 10. UserModel updateBio(String text) ---
  /// Membuat salinan model baru dengan bio yang diperbarui.
  UserModel updateBio(String text) {
    return copyWith(bio: text, updatedAt: DateTime.now());
  }

  // --- 11. UserModel merge(UserModel other) ---
  /// Menggabungkan data dari model lain ke model ini.
  /// Data dari [other] akan menimpa data yang ada di model ini,
  /// kecuali jika data di [other] adalah null/kosong dan data di model ini tidak.
  UserModel merge(UserModel other) {
    // Karena UserModel adalah immutable, kita gunakan copyWith.
    return copyWith(
      // ID harusnya tidak berubah, kita abaikan 'other.id'
      name: other.name.isNotEmpty ? other.name : name,
      email: other.email.isNotEmpty ? other.email : email,
      photoUrl: other.photoUrl ?? photoUrl,
      phone: other.phone ?? phone,
      isOnline: other.isOnline, // Status online selalu diupdate
      // createdAt tidak berubah
      updatedAt: DateTime.now(), // Selalu update updatedAt
      bio: other.bio ?? bio,
      role: other.role ?? role,
      extra: other.extra ?? extra, // Mengambil data extra dari 'other' jika ada
    );
  }

  // --- 12. Override == dan hashCode ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    // Untuk Map, kita perlu perbandingan yang lebih dalam, tapi untuk kepraktisan,
    // kita asumsikan perbandingan fields dasar sudah cukup.
    // Jika perlu perbandingan Map yang dalam, gunakan package seperti 'package:collection/collection.dart'.
    // Di sini, kita gunakan perbandingan standar untuk Map.
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.phone == phone &&
        other.isOnline == isOnline &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.bio == bio &&
        other.role == role &&
        other.extra.toString() == extra.toString(); // Perbandingan string untuk Map/extra
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        photoUrl,
        phone,
        isOnline,
        createdAt,
        updatedAt,
        bio,
        role,
        extra,
      );

  // --- 13. Override toString() ---

  @override
  String toString() {
    return 'UserModel(\n'
        '  id: $id,\n'
        '  name: $name,\n'
        '  email: $email,\n'
        '  photoUrl: $photoUrl,\n'
        '  phone: $phone,\n'
        '  isOnline: $isOnline,\n'
        '  createdAt: ${createdAt.toIso8601String()},\n'
        '  updatedAt: ${updatedAt.toIso8601String()},\n'
        '  bio: $bio,\n'
        '  role: $role,\n'
        '  extra: $extra\n'
        ')';
  }
}
