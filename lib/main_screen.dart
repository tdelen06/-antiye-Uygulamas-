import 'package:flutter/material.dart';
import 'main_screen.dart'; // Yeni oluşturduğun dosyayı buraya import et

void main() {
  runApp(const SantiyeApp());
}

class SantiyeApp extends StatelessWidget {
  const SantiyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şantiye Günlük Rapor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF12213A),
      ),
      // Uygulama açıldığında direkt alt menülü ana yöneticimiz (MainScreen) açılacak:
      home: const MainScreen(), 
    );
  }
}