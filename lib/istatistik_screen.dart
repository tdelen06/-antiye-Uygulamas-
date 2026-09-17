import 'package:flutter/material.dart';

class IstatistikScreen extends StatelessWidget {
  const IstatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        title: const Text('Proje İstatistikleri & Özet', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Genel İlerleme Durumu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const LinearProgressIndicator(value: 0.68, backgroundColor: Colors.white12, color: Colors.blueAccent, minHeight: 8),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Tamamlanan: %68', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Kalan: %32', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.trending_up, color: Colors.green, size: 28),
                      SizedBox(height: 12),
                      Text('Bütçe Kullanımı', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₺4.2M / ₺6.0M', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.security, color: Colors.blue, size: 28),
                      SizedBox(height: 12),
                      Text('İSG Puanı', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('94 / 100', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}