import 'package:flutter/material.dart';

class HavaDurumuScreen extends StatefulWidget {
  final String santiyeAdi;
  final String santiyeKonum;

  const HavaDurumuScreen({
    super.key, 
    this.santiyeAdi = 'Kurtuluş Konut Projesi',
    this.santiyeKonum = 'Ankara / Keçiören',
  });

  @override
  State<HavaDurumuScreen> createState() => _HavaDurumuScreenState();
}

class _HavaDurumuScreenState extends State<HavaDurumuScreen> {
  static const bg = Color(0xFF12213A);
  static const cardBg = Color(0xFF1B2C4A);

  bool _isRefreshing = false;

  // Şantiye konumuna göre simüle edilmiş dinamik güncellenen veriler
  String _anlikSicaklik = '18°C';
  String _durumMetni = 'Parçalı Bulutlu';
  String _yuksekDusuk = 'H: 22°   L: 12°';
  String _nem = '%65';
  String _ruzgar = '12 km/s';
  
  // Şantiye Operasyon Risk Durumu ('Güvenli', 'Az Riskli', 'Riskli')
  String _riskDurumu = 'Güvenli';
  Color _riskRengi = Colors.green;
  String _riskAciklamasi = 'Vinç, çatı ve beton döküm işleri için hava koşulları uygun.';

  final List<Map<String, dynamic>> _saatlik = [
    {'saat': '12:00', 'derece': 20.0, 'dereceStr': '20°', 'icon': Icons.wb_sunny, 'yagisRisk': '%0'},
    {'saat': '15:00', 'derece': 22.0, 'dereceStr': '22°', 'icon': Icons.wb_cloudy, 'yagisRisk': '%10'},
    {'saat': '18:00', 'derece': 19.0, 'dereceStr': '19°', 'icon': Icons.grain, 'yagisRisk': '%40'},
    {'saat': '21:00', 'derece': 16.0, 'dereceStr': '16°', 'icon': Icons.nightlight_round, 'yagisRisk': '%20'},
    {'saat': '00:00', 'derece': 14.0, 'dereceStr': '14°', 'icon': Icons.nightlight_round, 'yagisRisk': '%5'},
  ];

  final List<Map<String, String>> _gunler = [
    {'gun': 'Bugün', 'derece': '22° / 12°', 'durum': 'Parçalı Bulutlu'},
    {'gun': 'Yarın', 'derece': '21° / 11°', 'durum': 'Hafif Yağmurlu'},
    {'gun': 'Çarşamba', 'derece': '20° / 10°', 'durum': 'Güneşli'},
    {'gun': 'Perşembe', 'derece': '18° / 9°', 'durum': 'Rüzgarlı ve Bulutlu'},
    {'gun': 'Cuma', 'derece': '17° / 8°', 'durum': 'Açık'},
  ];

  // Şantiye konumuna göre verileri güncelleyen fonksiyon (Simüle edilmiş GPS/API yenileme)
  Future<void> _santiyeHavaDurumunuGuncelle() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // Servis gecikmesi simülasyonu

    setState(() {
      _isRefreshing = false;
      // Örnek simülasyon: Şantiye konumuna göre riskli moda geçiş testi
      _riskDurumu = 'Az Riskli';
      _riskRengi = Colors.orange;
      _riskAciklamasi = 'Akşam saat 18:00 civarı %40 yağış riski var. Dış saha elektrik işlerinde dikkat!';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.santiyeKonum} şantiye konumu için hava durumu güncellendi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Üst Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Şantiye Hava & Risk Durumu',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: _isRefreshing 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.refresh, color: Colors.white54),
                    onPressed: _santiyeHavaDurumunuGuncelle,
                    tooltip: "Şantiye Konumundan Yenile",
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Şantiye Bilgisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.santiyeKonum,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(widget.santiyeAdi,
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      // Akıllı Risk Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _riskRengi.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _riskRengi),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield_outlined, color: _riskRengi, size: 14),
                            const SizedBox(width: 6),
                            Text(_riskDurumu, style: TextStyle(color: _riskRengi, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 14),

                  // Saha Uyarı Notu Kartı
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _riskRengi.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _riskRengi.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: _riskRengi, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_riskAciklamasi,
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Anlık Hava Durumu Ana Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_cloudy, color: Colors.blueAccent, size: 48),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_anlikSicaklik, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            Text(_yuksekDusuk, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            Text(_durumMetni, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(children: [
                              const Icon(Icons.water_drop_outlined, color: Colors.white54, size: 14),
                              const SizedBox(width: 4),
                              Text(_nem, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.air, color: Colors.white54, size: 14),
                              const SizedBox(width: 4),
                              Text(_ruzgar, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Saatlik Tahmin ve Sıcaklık Dalgalanma Çizelgesi
                  const Text('Saatlik Dalgalanma & Yağış Riski', 
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _saatlik.map((s) {
                            return Column(
                              children: [
                                Text(s['saat'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 6),
                                Icon(s['icon'], color: Colors.white, size: 20),
                                const SizedBox(height: 6),
                                Text(s['dereceStr'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                // Yağış Risk Oranı
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: s['yagisRisk'] == '%0' ? Colors.transparent : Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(s['yagisRisk'], style: TextStyle(color: s['yagisRisk'] == '%0' ? Colors.white38 : Colors.blueAccent, fontSize: 10)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        // Basit Sıcaklık Dalgalanma Çizgisi Göstergesi
                        SizedBox(
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _saitlikDalgalanmaBar(_saatlik),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5 Günlük Tahmin Listesi
                  const Text('5 Günlük Şantiye Hava Tahmini', 
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: _gunler.map((g) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.wb_cloudy_outlined, color: Colors.blueAccent, size: 18),
                              const SizedBox(width: 12),
                              Text(g['gun']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              Text('(${g['durum']})', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              const Spacer(),
                              Text(g['derece']!, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bilgilendirme Alt Bandı
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on_outlined, color: Colors.blueAccent, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu veriler doğrudan şantiye şantiyenizin GPS konumuna göre meteoroloji servisinden çekilmektedir.',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Saatlik sıcaklık dalgalanmalarını görselleştiren çubuklar
  List<Widget> _saitlikDalgalanmaBar(List<Map<String, dynamic>> saatlikVeri) {
    return saatlikVeri.map((s) {
      double derece = s['derece'];
      // Basit yükseklik oranı hesaplama (10°C ile 30°C arası ölçekleme)
      double heightFactor = ((derece - 10) / 20).clamp(0.2, 1.0);

      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 20 * heightFactor + 5,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }).toList();
  }
}