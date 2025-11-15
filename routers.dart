// file: routes.dart

import 'package:flutter/material.dart';

// --- Imports Halaman ---
// Pastikan path ini sesuai dengan struktur folder proyek Anda.
import 'package:project/pages/splash_page.dart';
import 'package:project/pages/onboarding_page.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/register_page.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/pages/chat_page.dart';
import 'package:project/pages/chat_room_page.dart';
import 'package:project/pages/profile_page.dart';
import 'package:project/pages/settings_page.dart';
import 'package:project/pages/search_page.dart';
import 'package:project/pages/call_page.dart';
import 'package:project/pages/video_call_page.dart';
import 'package:project/pages/group_page.dart';
import 'package:project/pages/group_chat_page.dart';
import 'package:project/pages/admin/admin_page.dart';
import 'package:project/pages/errors/error_page.dart';
import 'package:project/pages/errors/missing_argument_page.dart';

/// Kelas statis untuk mengelola semua rute dan navigasi dalam aplikasi.
class AppRoutes {
  // --- 1. Static Log System ---
  static void _log(String message) {
    debugPrint('🚦 ROUTE LOG: $message');
  }

  // --- 2. Definisi Routes Utama ---
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String chatRoom = '/chatRoom';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String call = '/call';
  static const String videoCall = '/videoCall';
  static const String group = '/group';
  static const String groupChat = '/groupChat';
  static const String admin = '/admin';

  // --- 1. Static Map Routes (Semua Routes) ---
  static Map<String, Widget Function(BuildContext)> routes = {
    // Public Routes
    splash: (context) => const SplashPage(),
    onboarding: (context) => const OnboardingPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),

    // Protected Routes (Perlu validasi di onGenerateRoute)
    home: (context) => const HomePage(),
    chat: (context) => const ChatPage(),
    chatRoom: (context) => const ChatRoomPage(),
    profile: (context) => const ProfilePage(),
    settings: (context) => const SettingsPage(),
    search: (context) => const SearchPage(),
    call: (context) => const CallPage(),
    videoCall: (context) => const VideoCallPage(),
    group: (context) => const GroupPage(),
    groupChat: (context) => const GroupChatPage(),
    admin: (context) => const AdminPage(),
  };

  // --- 1. Static Map Protected Routes (Routes yang butuh login) ---
  static const Set<String> protectedRoutes = {
    home,
    chat,
    chatRoom,
    profile,
    settings,
    search,
    call,
    videoCall,
    group,
    groupChat,
    admin,
  };

  // --- 1. Static List Initial Routes (Route saat onboarding) ---
  static const List<String> initialRoutes = [
    splash,
    onboarding,
    login,
  ];

  // --- 1. Static Function isProtected(String route) ---
  /// Cek apakah suatu route membutuhkan otentikasi.
  static bool isProtected(String route) {
    return protectedRoutes.contains(route);
  }

  // --- 1. Static Function requiresAuth(RouteSettings settings) ---
  /// Implementasi placeholder untuk cek otentikasi.
  /// Dalam aplikasi nyata, ini akan berinteraksi dengan layanan Auth Anda.
  static bool requiresAuth(RouteSettings settings) {
    // Logika dummy: Anggap saja user sudah login setelah Onboarding
    if (settings.name != null && isProtected(settings.name!)) {
      // **Ganti dengan logika Auth sesungguhnya:**
      // return AuthService.isLoggedIn();
      // Untuk demo, kita asumsikan semua halaman utama perlu login kecuali Admin (yang butuh role).
      return settings.name != admin;
    }
    return false;
  }

  // --- 4. Parameter Wajib & Validasi ---

  static const Map<String, List<String>> _requiredArguments = {
    chatRoom: ['userId', 'username', 'avatarUrl'],
    call: ['callerId', 'receiverId', 'callType'],
    videoCall: ['callerId', 'receiverId', 'callType'],
    groupChat: ['groupId', 'groupName'],
  };

  // --- 1. Static Function validateArguments(...) ---
  /// Cek apakah argument yang diterima oleh halaman sudah lengkap.
  static bool validateArguments(
      RouteSettings settings, List<String> requiredKeys) {
    final args = settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      _log('⛔ VALIDATION ERROR: Route ${settings.name} membutuhkan argumen, tapi tidak ada yang diberikan.');
      return requiredKeys.isEmpty; // Jika tidak ada argumen dan tidak ada key wajib
    }

    bool isValid = true;
    for (var key in requiredKeys) {
      if (!args.containsKey(key) ||
          (args[key] == null || args[key].toString().isEmpty)) {
        _log('⛔ VALIDATION ERROR: Route ${settings.name} kehilangan key wajib: $key');
        isValid = false;
        break;
      }
    }
    return isValid;
  }

  // --- 5. Sistem onGenerateRoute (Fallback Error) ---

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final WidgetBuilder? builder = routes[routeName];
    final requiredKeys = _requiredArguments[routeName] ?? [];

    if (builder != null) {
      // 1. Cek Otentikasi (Contoh)
      if (requiresAuth(settings)) {
        _log('🔒 REDIRECT: ${settings.name} butuh login. Mengarahkan ke ${AppRoutes.login}');
        // Ganti dengan halaman otentikasi jika user belum login
        return MaterialPageRoute(builder: (context) => const LoginPage());
      }

      // 2. Cek Argumen Wajib
      if (requiredKeys.isNotEmpty &&
          !validateArguments(settings, requiredKeys)) {
        _log(
            '⛔ FALLBACK: ${settings.name} memiliki argumen yang hilang/tidak valid.');
        return MaterialPageRoute(
            builder: (context) => const MissingArgumentPage());
      }

      // 3. Log Navigasi & Build Halaman
      _log('➡️ NAVIGATING TO: $routeName');
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }

    // 4. Fallback jika Route tidak ditemukan
    _log('❌ ROUTE NOT FOUND: Route ${settings.name} tidak terdaftar.');
    return MaterialPageRoute(builder: (context) => const ErrorPage());
  }

  // --- 3. Fungsi Navigasi Siap Pakai ---

  /// Navigasi ke rute baru.
  static Future<T?> go<T extends Object?>(
      BuildContext context, String route) {
    _log('🚀 Go: $route');
    return Navigator.of(context).pushNamed<T>(route);
  }

  /// Navigasi ke rute baru dengan argumen.
  static Future<T?> goWithArgs<T extends Object?>(
      BuildContext context, String route, Map<String, dynamic> args) {
    _log('🚀 Go With Args: $route | Args: ${args.keys.join(', ')}');
    return Navigator.of(context).pushNamed<T>(route, arguments: args);
  }

  /// Mengganti rute saat ini dengan rute baru (menghilangkan rute saat ini dari stack).
  static Future<T?> replace<T extends Object?, TO extends Object?>(
      BuildContext context, String route,
      {TO? result}) {
    _log('🔄 Replace: $route');
    return Navigator.of(context).pushReplacementNamed<T, TO>(route, result: result);
  }

  /// Mengganti rute saat ini dengan rute baru dengan argumen.
  static Future<T?> replaceWithArgs<T extends Object?, TO extends Object?>(
      BuildContext context, String route, Map<String, dynamic> args,
      {TO? result}) {
    _log('🔄 Replace With Args: $route | Args: ${args.keys.join(', ')}');
    return Navigator.of(context)
        .pushReplacementNamed<T, TO>(route, arguments: args, result: result);
  }

  /// Kembali ke rute sebelumnya.
  static void back(BuildContext context) {
    _log('↩️ Back');
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Kembali ke rute sebelumnya dengan hasil.
  static void backWithResult<T extends Object?>(
      BuildContext context, T result) {
    _log('↩️ Back With Result: $result');
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(result);
    }
  }
}
