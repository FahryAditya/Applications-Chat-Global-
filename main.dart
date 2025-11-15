import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// --- Root Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      // Menetapkan tema dasar dengan Primary Color Biru
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Opsi lain: primaryColor: Colors.blue,
        // useMaterial3: true,
      ),
      
      // Menetapkan halaman awal ke '/login'
      initialRoute: '/login',
      
      // Mendefinisikan rute aplikasi
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

// --- LoginPage Widget ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Ini adalah Halaman Login',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke Halaman Home
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Login & Ke Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HomePage Widget ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Utama'),
        // AppBar di HomePage tidak perlu tombol back jika navigasi dari login 
        // menggunakan pushReplacementNamed.
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Selamat Datang di Halaman Utama!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi kembali ke Halaman Login
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout & Ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}
