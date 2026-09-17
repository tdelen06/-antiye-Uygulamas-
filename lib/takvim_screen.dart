import 'package:flutter/material.dart';

class TakvimScreen extends StatefulWidget {
  const TakvimScreen({super.key});

  @override
  State<TakvimScreen> createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  // Gerçek sistem/bugünün tarihi (16 Eylül 2026)
  final int gercekBugunGun = 16;
  final int gercekBugunAy = 9;
  final int gercekBugunYil = 2026;

  // Kullanıcının şu an ekranda seçtiği gün (Başlangıçta bugün seçili)
  int? secilenGun = 16;
  int secilenAy = 9;
  int secilenYil = 2026;
  int yilBlokBaslangici = 2017;

  // Etkinlikler / Notlar veritabanı simülasyonu
  final Map<String, List<Map<String, dynamic>>> gunlukIsler = {
    '12_9_2026': [
      {'saat': '08:00', 'baslik': 'Beton dökümü', 'renk': Colors.green},
      {'saat': '13:00', 'baslik': 'Elektrik pano montajı', 'renk': Colors.blue},
    ],
    '16_9_2026': [
      {'saat': '10:00', 'baslik': 'İSG Denetimi', 'renk': Colors.blueAccent},
    ],
  };

  final List<String> aylar = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  String _ayAdiGetir(int ay) {
    if (ay < 1 || ay > 12) return '';
    return aylar[ay];
  }

  int _aydakiGunSayisi(int yil, int ay) {
    if (ay == 2) {
      bool artikYil = (yil % 4 == 0) && (yil % 100 != 0 || yil % 400 == 0);
      return artikYil ? 29 : 28;
    }
    const gunler = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return gunler[ay];
  }

  int _ayinIlkGunBaslangici(int yil, int ay) {
    DateTime ilkGun = DateTime(yil, ay, 1);
    return ilkGun.weekday - 1;
  }

  void _ayDegistir(int yon) {
    setState(() {
      secilenAy += yon;
      if (secilenAy > 12) {
        secilenAy = 1;
        secilenYil++;
      } else if (secilenAy < 1) {
        secilenAy = 12;
        secilenYil--;
      }
      // Eğer yeni gelinen ay "bugün"ün ayı ise otomatik bugün seçilsin, değilse seçim boşalsın
      if (secilenYil == gercekBugunYil && secilenAy == gercekBugunAy) {
        secilenGun = gercekBugunGun;
      } else {
        secilenGun = null;
      }
    });
  }

  void _yilSecDialogu() {
    yilBlokBaslangici = ((secilenYil - 2017) ~/ 20) * 20 + 2017;
    if (secilenYil < 2017) {
      yilBlokBaslangici = 2017 - (((2017 - secilenYil) ~/ 20) + 1) * 20;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int blokBitis = yilBlokBaslangici + 19;

            return AlertDialog(
              backgroundColor: const Color(0xFF1B2C4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 280,
                height: 260,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.blueAccent, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              yilBlokBaslangici -= 20;
                            });
                          },
                        ),
                        Text(
                          '$yilBlokBaslangici - $blokBitis',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.blueAccent, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              yilBlokBaslangici += 20;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: 20,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.6,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          int yil = yilBlokBaslangici + index;
                          bool seciliOlan = (yil == secilenYil);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                secilenYil = yil;
                                if (secilenYil == gercekBugunYil && secilenAy == gercekBugunAy) {
                                  secilenGun = gercekBugunGun;
                                } else {
                                  secilenGun = null;
                                }
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: seciliOlan ? Colors.blueAccent : const Color(0xFF12213A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: seciliOlan ? Colors.white : Colors.white10),
                              ),
                              child: Text(
                                '$yil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: seciliOlan ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Seçilen güne yeni not / etkinlik ekleme diyaloğu
  void _notEkleDialogu() {
    if (secilenGun == null) return;

    TextEditingController saatController = TextEditingController(text: '09:00');
    TextEditingController baslikController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2C4A),
          title: Text(
            '$secilenGun ${_ayAdiGetir(secilenAy)} $secilenYil - Not Ekle',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: saatController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Saat (Örn: 14:30)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: baslikController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'İş / Etkinlik Açıklaması',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                if (baslikController.text.isNotEmpty) {
                  String key = '${secilenGun}_${secilenAy}_$secilenYil';
                  setState(() {
                    if (!gunlukIsler.containsKey(key)) {
                      gunlukIsler[key] = [];
                    }
                    gunlukIsler[key]!.add({
                      'saat': saatController.text,
                      'baslik': baslikController.text,
                      'renk': Colors.orangeAccent,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    String key = '${secilenGun ?? 0}_${secilenAy}_$secilenYil';
    final aktifIsler = secilenGun != null ? (gunlukIsler[key] ?? []) : [];

    int toplamGun = _aydakiGunSayisi(secilenYil, secilenAy);
    int boslukSayisi = _ayinIlkGunBaslangici(secilenYil, secilenAy);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Şantiye Takvimi',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // TAKVİM KUTUSU
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.chevron_left, color: Colors.blueAccent, size: 24),
                                onPressed: () => _ayDegistir(-1),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _ayAdiGetir(secilenAy),
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _yilSecDialogu,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$secilenYil',
                                        style: const TextStyle(color: Colors.blueAccent, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.chevron_right, color: Colors.blueAccent, size: 24),
                                onPressed: () => _ayDegistir(1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Pzt', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Sal', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Çar', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Per', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Cum', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Cmt', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Paz', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // GÜN KUTULARI
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: toplamGun + boslukSayisi,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.5,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemBuilder: (context, index) {
                              if (index < boslukSayisi) {
                                return const SizedBox.shrink();
                              }

                              int gun = index - boslukSayisi + 1;
                              bool bugunMu = (gun == gercekBugunGun && secilenAy == gercekBugunAy && secilenYil == gercekBugunYil);
                              bool seciliMi = (secilenGun == gun);
                              String loopKey = '${gun}_${secilenAy}_$secilenYil';
                              bool etkinlikVarMi = gunlukIsler.containsKey(loopKey);

                              // Renk Mantığı: 
                              // 1. Seçilen gün farklı/belirgin bir renkte (Örn: Beyaz üstü koyu yazı veya açık mavi)
                              // 2. Bugün ise her zaman mavi daire ile işaretli kalır.
                              Color? arkaplanRengi;
                              Color yaziRengi = Colors.white70;

                              if (seciliMi) {
                                arkaplanRengi = Colors.white; // Seçilen gün beyaz arka plan
                                yaziRengi = Colors.black87;
                              } else if (bugunMu) {
                                arkaplanRengi = Colors.blueAccent.withOpacity(0.4); // Bugün hafif mavi vurgulu
                                yaziRengi = Colors.white;
                              }

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    secilenGun = gun;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: arkaplanRengi,
                                          shape: BoxShape.circle,
                                          border: bugunMu && !seciliMi ? Border.all(color: Colors.blueAccent, width: 1.5) : null,
                                        ),
                                        child: Text(
                                          '$gun',
                                          style: TextStyle(
                                            color: yaziRengi,
                                            fontSize: 12,
                                            fontWeight: seciliMi || bugunMu ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SizedBox(
                                        height: 3,
                                        child: etkinlikVarMi
                                            ? Container(
                                                width: 3,
                                                height: 3,
                                                decoration: BoxDecoration(
                                                  color: seciliMi ? Colors.black54 : Colors.blueAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.white12),

                    // ALT KISIM: SEÇİLEN GÜN VE NOT EKLEME
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            secilenGun != null
                                ? '$secilenGun ${_ayAdiGetir(secilenAy)} $secilenYil'
                                : 'Bir gün seçiniz',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          if (secilenGun != null)
                            TextButton.icon(
                              onPressed: _notEkleDialogu,
                              icon: const Icon(Icons.add, size: 14, color: Colors.blueAccent),
                              label: const Text('Not Ekle', style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),

                    secilenGun == null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'Görüntülemek için takvimden bir gün seçin.',
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          )
                        : aktifIsler.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Text(
                                  'Bu tarihte planlanmış etkinlik bulunmuyor.',
                                  style: TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: aktifIsler.length,
                                itemBuilder: (context, index) {
                                  final isModel = aktifIsler[index];
                                  Color renk = isModel['renk'];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 6, height: 6, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
                                        const SizedBox(width: 8),
                                        Text(isModel['saat'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            isModel['baslik'],
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}