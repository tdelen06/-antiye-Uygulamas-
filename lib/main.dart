import 'package:flutter/material.dart';
import 'auth_screen.dart'; // <-- Güvenli oda ve rol giriş ekranımız
import 'dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şantiye Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12213A),
        primarySwatch: Colors.blue,
      ),
      // Uygulama açılışında doğrudan şık SplashScreen'imiz gelsin:
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12213A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.engineering, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Şantiye Şefi',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daha Güvenli ve Verimli Şantiyeler',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const Spacer(flex: 4),
              
              // Giriş Yap Butonu -> AuthScreen'e yönlendirir (Hata veren const kaldırıldı)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Giriş Yap / Odaya Katıl', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              
              // Kayıt Ol Butonu -> Yine AuthScreen'e yönlendirir
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kayıt Ol', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const Spacer(flex: 1),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Sahada kontrol, ofiste plan, her zaman seninle.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}