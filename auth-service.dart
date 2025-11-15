// file: auth_service.dart
​import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/models/user_model.dart'; // Ganti dengan path UserModel Anda
​/// Service untuk mengelola otentikasi dan data user menggunakan REST API.
class AuthService {
// --- Konfigurasi Statis ---
static const String baseUrl = 'https://api.yourdomain.com/v1/auth';
static const String _tokenKey = 'auth_token';
static const String _userKey = 'current_user';
​// --- Logger Internal ---
static void _debugLog(String message) {
print('🔑 AUTH SERVICE LOG: $message');
}
​// --- Fungsi Manipulasi Token (Internal/SharedPrefs) ---
​/// Menyimpan token otentikasi ke Shared Preferences.
static Future<void> saveToken(String token) async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString(_tokenKey, token);
_debugLog('Token saved successfully.');
}
​/// Mengambil token otentikasi dari Shared Preferences.
static Future<String?> getToken() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
return prefs.getString(_tokenKey);
}
​/// Menghapus token otentikasi dari Shared Preferences.
static Future<void> deleteToken() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.remove(_tokenKey);
_debugLog('Token deleted.');
}
​// --- Fungsi Manipulasi User Model (Internal/SharedPrefs) ---
​/// Menyimpan data UserModel ke Shared Preferences sebagai JSON String.
static Future<void> saveUser(UserModel user) async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
final String userJson = jsonEncode(user.toJson());
await prefs.setString(_userKey, userJson);
_debugLog('User data saved: ${user.name}');
}
​/// Mengambil data UserModel dari Shared Preferences.
static Future<UserModel?> getUser() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
final String? userJson = prefs.getString(_userKey);
if (userJson != null) {
try {
final Map<String, dynamic> map = jsonDecode(userJson);
return UserModel.fromJson(map);
} catch (e) {
_debugLog('Error decoding user JSON: $e');
return null;
}
}
return null;
}
​/// Menghapus data user dari Shared Preferences.
static Future<void> deleteUser() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.remove(_userKey);
_debugLog('User data deleted.');
}
​// --- Fungsi Utama Otentikasi & API ---
​/// 1. Melakukan proses login dan menyimpan token/user.
static Future<UserModel> login(String email, String password) async {
_debugLog('Attempting to login user: $email');
final uri = Uri.parse('$baseUrl/login');
try {
final response = await http.post(
uri,
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'email': email, 'password': password}),
);
