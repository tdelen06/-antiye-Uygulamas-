import 'package:flutter/material.dart';

class IsTakibiScreen extends StatefulWidget {
  const IsTakibiScreen({super.key});

  @override
  State<IsTakibiScreen> createState() => _IsTakibiScreenState();
}

class _IsTakibiScreenState extends State<IsTakibiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _gunlukRaporlarArsivi = [
    {
      'gun': '1. Gün (02.09.2026)',
      'hava': 'Güneşli, 28°C',
      'notlar': 'Saha kazı çalışmaları tamamlandı. Temel aplikasyonları atıldı.',
      'fotolar': 2,
    },
    {
      'gun': '2. Gün (03.09.2026)',
      'hava': 'Parçalı Bulutlu, 26°C',
      'notlar': 'Grobeton dökümü gerçekleştirildi. Demirciler demir bağlama işlemine başladı.',
      'fotolar': 4,
    },
    {
      'gun': '7. Gün (08.09.2026 - Dün)',
      'hava': 'Açık, 25°C',
      'notlar': 'A Katı tabliye betonu atıldı. Elektrik alt yapı boruları döşendi.',
      'fotolar': 3,
    },
  ];

  final List<Map<String, dynamic>> _isListesi = [
    {
      'baslik': 'Bugünkü Beton dökümü', 
      'tarih': '09.09.2026 (Bugün)', 
      'durum': 'Tamamlandı', 
      'renk': Colors.green, 
      'detay': 'A Katı tabliye betonu vibratör eşliğinde atıldı.',
      'fotoVar': true,
    },
    {
      'baslik': 'Elektrik pano montajı', 
      'tarih': '10.09.2026 (Yarın)', 
      'durum': 'Planlandı', 
      'renk': Colors.purple, 
      'detay': 'Ana dağıtım panosu kablolaması yapılacak.',
      'fotoVar': false,
    },
    {
      'baslik': 'Haftalık İskele Kontrolü', 
      'tarih': '15.09.2026 (Gelecek Hafta)', 
      'durum': 'Planlandı', 
      'renk': Colors.blue, 
      'detay': 'İSG açısından tüm dış cephe iskeleleri denetlenecek.',
      'fotoVar': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Görev Ekleme veya Güncelleme Ortak Modalı
  void _gorevEkleGuncelleModal(BuildContext context, {int? index}) {
    final bool guncellemeMi = index != null;
    final gorev = guncellemeMi ? _isListesi[index] : null;

    final baslikController = TextEditingController(text: gorev?['baslik'] ?? '');
    final detayController = TextEditingController(text: gorev?['detay'] ?? '');
    bool fotoEklendiMi = gorev?['fotoVar'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2C4A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guncellemeMi ? 'Görevi Düzenle' : 'İleri Tarihli İş veya Günlük Not Ekle',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: baslikController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Görev / İş Başlığı',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detayController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Detaylar ve Açıklama',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: fotoEklendiMi ? Colors.green : Colors.white24),
                          ),
                          icon: Icon(fotoEklendiMi ? Icons.check_circle : Icons.camera_alt, 
                              color: fotoEklendiMi ? Colors.green : Colors.white54),
                          label: Text(fotoEklendiMi ? 'Fotoğraf Eklendi (1)' : 'Saha Fotoğrafı Ekle',
                              style: TextStyle(color: fotoEklendiMi ? Colors.green : Colors.white54)),
                          onPressed: () {
                            setModalState(() {
                              fotoEklendiMi = !fotoEklendiMi;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      onPressed: () {
                        if (baslikController.text.isNotEmpty) {
                          setState(() {
                            if (guncellemeMi) {
                              _isListesi[index] = {
                                'baslik': baslikController.text,
                                'tarih': gorev!['tarih'],
                                'durum': gorev['durum'],
                                'renk': gorev['renk'],
                                'detay': detayController.text.isEmpty ? 'Açıklama yok' : detayController.text,
                                'fotoVar': fotoEklendiMi,
                              };
                            } else {
                              _isListesi.insert(0, {
                                'baslik': baslikController.text,
                                'tarih': 'İleri Tarihli Plan',
                                'durum': 'Planlandı',
                                'renk': Colors.blue,
                                'detay': detayController.text.isEmpty ? 'Açıklama yok' : detayController.text,
                                'fotoVar': fotoEklendiMi,
                              });
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        guncellemeMi ? 'Değişiklikleri Kaydet' : 'Takvime ve Görevlere Ekle', 
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
        title: const Text('İş Takibi ve Günlük Raporlar', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Güncel İşler & Takvim'),
            Tab(text: 'Geçmiş Raporlar Arşivi'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _gorevEkleGuncelleModal(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Güncel Görevler ve İleri Tarihli Planlar
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _isListesi.length,
            itemBuilder: (context, index) {
              final gorev = _isListesi[index];
              return Dismissible(
                key: Key(gorev['baslik']! + index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() => _isListesi.removeAt(index));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(width: 8, height: 45, decoration: BoxDecoration(color: gorev['renk'], borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gorev['baslik'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${gorev['tarih']} • ${gorev['detay']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            if (gorev['fotoVar']) ...[
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(Icons.photo_camera, size: 14, color: Colors.blueAccent),
                                  SizedBox(width: 4),
                                  Text('Saha Fotoğrafı Eklendi', style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: gorev['renk'].withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                        child: Text(gorev['durum'], style: TextStyle(color: gorev['renk'], fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 4),
                      // Düzenleme Butonu Eklendi
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                        onPressed: () => _gorevEkleGuncelleModal(context, index: index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // TAB 2: Geçmiş Günlük Raporlar Arşivi
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _gunlukRaporlarArsivi.length,
            itemBuilder: (context, index) {
              final rapor = _gunlukRaporlarArsivi[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rapor['gun'], style: const TextStyle(color: Colors.blueAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(rapor['hava'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Text(rapor['notlar'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.image, size: 16, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text('${rapor['fotolar']} Adet Saha Fotoğrafı', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _gorevEkleGuncelleModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}