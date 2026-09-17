import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GunlukRaporScreen extends StatefulWidget {
  final String santiyeTuru;
  final String santiyeKonumHavaDurumu; // Ana sayfadan gelen şantiye hava durumu verisi

  const GunlukRaporScreen({
    super.key, 
    this.santiyeTuru = 'GES (Güneş Enerji Santrali)',
    this.santiyeKonumHavaDurumu = 'Ankara / Keçiören - 18°C, Parçalı Bulutlu',
  });

  @override
  State<GunlukRaporScreen> createState() => _GunlukRaporScreenState();
}

class _GunlukRaporScreenState extends State<GunlukRaporScreen> {
  final Map<String, List<String>> _hazirSablonlar = {
    'GES (Güneş Enerji Santrali)': [
      'OG Hattı Kanal Kazısı & Kablo',
      'AG Hattı ve Direk Dikimi',
      'TM (Trafo Merkezi) Binası ve Beton',
      'Saha Çit ve Topraklama İşleri',
      'Panel Montajı ve Konstrüksiyon',
    ],
    'Üstyapı / Konut Projesi': [
      'Temel Kazısı ve Hafriyat',
      'Kalıp ve Demir Donatı',
      'Beton Dökümü',
      'Tuver / Duvar Örgü İşleri',
      'İç Tesisat (Elektrik / Sıhhi Tesisat)',
    ],
    'Altyapı Projesi': [
      'Hat Güzergahı ve Kazı',
      'Yataklama ve Kum Serimi',
      'Künk / Boru Montajı',
      'Sızdırmazlık Basınç Testi',
      'Geri Dolgu ve Sıkıştırma',
    ],
  };

  final List<Map<String, dynamic>> _secilenSahaIsleri = [
    {'baslik': 'OG Hattı Kanal Kazısı & Kablo', 'tamamlandi': false, 'fotoVar': false},
    {'baslik': 'TM (Trafo Merkezi) Binası ve Beton', 'tamamlandi': true, 'fotoVar': true},
  ];

  final TextEditingController _genelNotController = TextEditingController();
  final TextEditingController _ozelIsController = TextEditingController();

  void _hazirIsEkle(String isAdi) {
    if (_secilenSahaIsleri.any((element) => element['baslik'] == isAdi)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$isAdi" zaten bugünkü rapor listesinde ekli!')),
      );
      return;
    }

    setState(() {
      _secilenSahaIsleri.add({
        'baslik': isAdi,
        'tamamlandi': false,
        'fotoVar': false,
      });
    });
  }

  void _ozelIsEkleModal(BuildContext context) {
    _ozelIsController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2C4A),
          title: const Text('Özel / Ekstra Saha İşi Ekle', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: _ozelIsController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Örn: Ana Dağıtım Panosu Revizyonu',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                if (_ozelIsController.text.trim().isNotEmpty) {
                  setState(() {
                    _secilenSahaIsleri.add({
                      'baslik': _ozelIsController.text.trim(),
                      'tamamlandi': false,
                      'fotoVar': false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Raporu Şantiye Konum Hava Durumuyla Birlikte Arşive Kaydetme
  Future<void> _raporuArsiveKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    
    final yeniRapor = {
      'tarih': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
      'santiyeTuru': widget.santiyeTuru,
      'havaDurumu': widget.santiyeKonumHavaDurumu, // Şantiyenin kayıtlı olduğu konum hava durumu
      'notlar': _genelNotController.text,
      'isler': _secilenSahaIsleri,
    };

    List<String> kayitliRaporlarStr = prefs.getStringList('kayitli_santiye_raporlari') ?? [];
    kayitliRaporlarStr.add(jsonEncode(yeniRapor));
    await prefs.setStringList('kayitli_santiye_raporlari', kayitliRaporlarStr);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapor şantiye konumu hava durumuyla birlikte arşive kaydedildi! 🗂️')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    final mevcutSablonlar = _hazirSablonlar[widget.santiyeTuru] ?? _hazirSablonlar['GES (Güneş Enerji Santrali)']!;

    int toplam = _secilenSahaIsleri.length;
    int biten = _secilenSahaIsleri.where((i) => i['tamamlandi'] == true).length;
    double ilerlemeYuzdesi = toplam == 0 ? 0.0 : (biten / toplam) * 100.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text('Günlük Rapor & Takip (${widget.santiyeTuru})', style: const TextStyle(color: Colors.white, fontSize: 14)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Üst Bilgi ve İlerleme Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.blueAccent, size: 22),
                    SizedBox(width: 8),
                    Text('Hızlı Saha Raporlama', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aşağıdaki hazır şablonlardan bugünkü sahada çalışılan hatları seçin veya tek dokunuşla ekleyerek fotoğraflandırın.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bugünkü Tamamlanma:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('%${ilerlemeYuzdesi.toInt()}', style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ilerlemeYuzdesi / 100.0,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hazır Şablon Çipleri
          const Text('Hızlı Seçim (Sık Kullanılanlar):', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mevcutSablonlar.map((sablon) {
              return ActionChip(
                backgroundColor: const Color(0xFF1B2C4A),
                side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                avatar: const Icon(Icons.add, color: Colors.blueAccent, size: 16),
                label: Text(sablon, style: const TextStyle(color: Colors.white, fontSize: 12)),
                onPressed: () => _hazirIsEkle(sablon),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bugün Sahada Çalışılanlar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => _ozelIsEkleModal(context),
                icon: const Icon(Icons.edit_note, size: 18, color: Colors.blueAccent),
                label: const Text('Özel Ekle', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_secilenSahaIsleri.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Henüz bugünkü rapora bir iş eklenmedi. Yukarıdan seçebilirsiniz.', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center)),
            ),

          ..._secilenSahaIsleri.asMap().entries.map((entry) {
            int index = entry.key;
            var isKalemi = entry.value;
            bool bitti = isKalemi['tamamlandi'];
            bool fotoVar = isKalemi['fotoVar'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: bitti ? Colors.green.withOpacity(0.5) : Colors.white10),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: bitti,
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        _secilenSahaIsleri[index]['tamamlandi'] = val!;
                        if (val) _secilenSahaIsleri[index]['fotoVar'] = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKalemi['baslik'],
                          style: TextStyle(
                            color: bitti ? Colors.white : Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: bitti ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.camera_alt, size: 13, color: fotoVar ? Colors.green : Colors.blueAccent),
                            const SizedBox(width: 4),
                            Text(
                              fotoVar ? 'Saha Fotoğrafı Eklendi' : 'Fotoğraf Yükle (Zorunlu)',
                              style: TextStyle(color: fotoVar ? Colors.green : Colors.blueAccent, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      setState(() {
                        _secilenSahaIsleri.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          const Text('Şantiye Şefi Notu / Açıklama', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _genelNotController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Hava muhalefeti, özel durumlar veya malzeme sevkiyat notları...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // Kaydet Butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _raporuArsiveKaydet,
              child: const Text('Günlük Raporu Onayla ve Arşive Gönder', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}