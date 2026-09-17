import 'package:flutter/material.dart';

class SantiyeYonetimDrawer extends StatefulWidget {
  final Function(Map<String, String>) onSantiyeSecildi;

  const SantiyeYonetimDrawer({super.key, required this.onSantiyeSecildi});

  @override
  State<SantiyeYonetimDrawer> createState() => _SantiyeYonetimDrawerState();
}

class _SantiyeYonetimDrawerState extends State<SantiyeYonetimDrawer> {
  List<Map<String, String>> santiyeListesi = [
    {
      'ad': 'Kurtuluş Konut Projesi',
      'konum': 'Ankara / Keçiören',
      'hava': '18°C, Parçalı Bulutlu',
      'personel': '24 Personel',
      'durum': 'Aktif / Devam Ediyor',
    },
    {
      'ad': 'Güneş Enerji Santrali (GES)',
      'konum': 'İzmir / Aliağa',
      'hava': '26°C, Güneşli',
      'personel': '42 Personel',
      'durum': 'Kritik Safha',
    },
    {
      'ad': '100. Yıl Altyapı Hattı',
      'konum': 'Ankara / Çankaya',
      'hava': '17°C, Hafif Yağmurlu',
      'personel': '15 Personel',
      'durum': 'Normal',
    },
  ];

  void _yeniSantiyeEkleModal(BuildContext context) {
    final TextEditingController adController = TextEditingController();
    final TextEditingController konumController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2C4A),
          title: const Text('Yeni Şantiye / Proje Ekle', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Şantiye / Proje Adı',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintText: 'Örn: Batıkent Villaları',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: konumController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Konum (İl / İlçe)',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintText: 'Örn: Ankara / Yenimahalle',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                if (adController.text.trim().isNotEmpty && konumController.text.trim().isNotEmpty) {
                  setState(() {
                    santiyeListesi.add({
                      'ad': adController.text.trim(),
                      'konum': konumController.text.trim(),
                      'hava': '20°C, Güneşli',
                      'personel': '0 Personel',
                      'durum': 'Yeni Başladı',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni şantiye başarıyla sisteme eklendi! 🏗️')),
                  );
                }
              },
              child: const Text('Kaydet ve Aç', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF12213A),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1B2C4A)),
            accountName: const Text('Tunahan Delen (Şantiye Koordinatörü)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            accountEmail: const Text('CEO / Üst Yönetim Paneli', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.3),
              child: const Icon(Icons.business, color: Colors.white, size: 28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktif Şantiyeler (${santiyeListesi.length})', 
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 22),
                  onPressed: () => _yeniSantiyeEkleModal(context),
                  tooltip: "Yeni Şantiye Ekle",
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.builder(
              itemCount: santiyeListesi.length,
              itemBuilder: (context, index) {
                var santiye = santiyeListesi[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2C4A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.blueAccent),
                    title: Text(santiye['ad']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text(santiye['konum']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny, size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(santiye['hava']!, style: const TextStyle(color: Colors.amber, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                    onTap: () {
                      widget.onSantiyeSecildi(santiye);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Şantiye Şefi V2.6 - Çoklu Proje', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}