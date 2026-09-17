import 'package:flutter/material.dart';

class AracGerecScreen extends StatefulWidget {
  const AracGerecScreen({super.key});

  @override
  State<AracGerecScreen> createState() => _AracGerecScreenState();
}

class _AracGerecScreenState extends State<AracGerecScreen> {
  final List<Map<String, String>> _aracListesi = [
    {'ad': 'JCB 4CX Ekskavatör', 'plaka': '06 ABC 34', 'durum': 'Saha Çalışmasında', 'tip': 'İş Makinesi'},
    {'ad': 'Ford Cargo Damperli Kamyon', 'plaka': '06 XYZ 78', 'durum': 'Sevkiyatta', 'tip': 'Kamyon'},
    {'ad': 'Genel Tip Seyyar Jeneratör', 'plaka': 'Demirbaş-01', 'durum': 'Aktif / Beklemede', 'tip': 'Ekipman'},
  ];

  void _aracEkleGuncelleModal(BuildContext context, {int? index}) {
    final bool guncellemeMi = index != null;
    final arac = guncellemeMi ? _aracListesi[index] : null;

    final adController = TextEditingController(text: arac?['ad'] ?? '');
    final plakaController = TextEditingController(text: arac?['plaka'] ?? '');
    final tipController = TextEditingController(text: arac?['tip'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2C4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guncellemeMi ? 'Araç / Ekipman Düzenle' : 'Yeni Araç / Ekipman Ekle',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Araç / Ekipman Adı',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plakaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Plaka / Demirbaş No',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tipController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tipi (Kamyon, Ekskavatör, Ekipman vb.)',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  onPressed: () {
                    if (adController.text.isNotEmpty) {
                      setState(() {
                        if (guncellemeMi) {
                          _aracListesi[index] = {
                            'ad': adController.text,
                            'plaka': plakaController.text.isEmpty ? '-' : plakaController.text,
                            'durum': arac!['durum'] ?? 'Saha Çalışmasında',
                            'tip': tipController.text.isEmpty ? 'Araç' : tipController.text,
                          };
                        } else {
                          _aracListesi.add({
                            'ad': adController.text,
                            'plaka': plakaController.text.isEmpty ? '-' : plakaController.text,
                            'durum': 'Saha Çalışmasında',
                            'tip': tipController.text.isEmpty ? 'Araç' : tipController.text,
                          });
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    guncellemeMi ? 'Değişiklikleri Kaydet' : 'Kaydet ve Ekle',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        title: const Text('Şantiye Araç & Gereç', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add),
            onPressed: () => _aracEkleGuncelleModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _aracListesi.length,
        itemBuilder: (context, index) {
          final arac = _aracListesi[index];

          return Dismissible(
            key: Key(arac['ad']! + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _aracListesi.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${arac['ad']} listeden çıkarıldı')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(arac['ad']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${arac['plaka']} • ${arac['tip']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      arac['durum']!,
                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sadece kaleme tıklandığında düzenleme açılır (Yanlışlıkla tıklama riski ortadan kalkar)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                    onPressed: () => _aracEkleGuncelleModal(context, index: index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _aracEkleGuncelleModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}