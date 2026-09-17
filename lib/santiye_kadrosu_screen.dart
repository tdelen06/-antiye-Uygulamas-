import 'package:flutter/material.dart';

class SantiyeKadrosuScreen extends StatelessWidget {
  const SantiyeKadrosuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1B2C4A);

    return Drawer(
      backgroundColor: const Color(0xFF12213A),
      child: SafeArea(
        child: Column(
          children: [
            // Üst Başlık ve Kapatma Butonu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.engineering, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Şantiye Yönetim Paneli', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Proje Ekibi ve Kadro', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // Kadro Listesi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('PATRON / CEO (YETKİLİLER)', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _KadroCard(
                    isim: 'Caner Kaya',
                    unvan: 'Genel Yönetim & Finans',
                    durum: 'Merkez Ofis',
                    durumRenk: Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  const Text('PROJE MÜDÜRÜ', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _KadroCard(
                    isim: 'Tunahan Delen',
                    unvan: 'Şantiye Proje Müdürü',
                    durum: 'Sahada / Çalışıyor',
                    durumRenk: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),

                  const Text('TEKNİK KADRO / MÜHENDİSLER', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _KadroCard(
                    isim: 'Ahmet Yılmaz',
                    unvan: 'Elektrik Mühendisi',
                    durum: 'Sahada / Çalışıyor',
                    durumRenk: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _KadroCard(
                    isim: 'Mehmet Demir',
                    unvan: 'Makine Mühendisi',
                    durum: 'İzinde',
                    durumRenk: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KadroCard extends StatelessWidget {
  final String isim;
  final String unvan;
  final String durum;
  final Color durumRenk;

  const _KadroCard({
    required this.isim,
    required this.unvan,
    required this.durum,
    required this.durumRenk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2C4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white12,
            child: const Icon(Icons.person, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(unvan, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: durumRenk.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(durum, style: TextStyle(color: durumRenk, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}