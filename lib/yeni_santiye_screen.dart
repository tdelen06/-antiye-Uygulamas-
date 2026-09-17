import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'turkiye_data.dart';

class YeniSantiyeScreen extends StatefulWidget {
  const YeniSantiyeScreen({super.key});

  @override
  State<YeniSantiyeScreen> createState() => _YeniSantiyeScreenState();
}

class _YeniSantiyeScreenState extends State<YeniSantiyeScreen> {
  int _aktifAdim = 1;
  double _sonZoom = 15.0; // Harita için varsayılan ideal zoom seviyesi

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _ulkeController = TextEditingController();
  final TextEditingController _ilController = TextEditingController();
  final TextEditingController _ilceController = TextEditingController();
  final TextEditingController _enlemController = TextEditingController();
  final TextEditingController _boylamController = TextEditingController();

  String? _secilenUlke = 'Türkiye';
  String? _secilenIl;
  String? _secilenIlce;
  double? _secilenEnlem;
  double? _secilenBoylam;
  bool _adresYukleniyor = false;

  final List<String> _iller = turkiyeIlIlce.keys.toList();
  final Map<String, List<String>> _ilceler = turkiyeIlIlce;

  final List<String> _santiyeTurleri = [
    'GES (Güneş Enerji Santrali)',
    'RES (Rüzgar Enerji Santrali)',
    'Üstyapı / Konut Projesi',
    'Altyapı Projesi',
    'Endüstriyel Tesis / Fabrika'
  ];
  String? _secilenSantiyeTuru;
  final TextEditingController _kapasiteController = TextEditingController();

  static const bg = Color(0xFF12213A);
  static const cardBg = Color(0xFF1B2C4A);

  @override
  void initState() {
    super.initState();
    _varsayilanKonumuYukle();
  }

  Future<void> _varsayilanKonumuYukle() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _secilenEnlem = position.latitude;
        _secilenBoylam = position.longitude;
        _enlemController.text = position.latitude.toStringAsFixed(6);
        _boylamController.text = position.longitude.toStringAsFixed(6);
      });
      await _koordinattanAdreseGit(position.latitude, position.longitude);
    } catch (_) {
      setState(() {
        _secilenEnlem = 39.9334;
        _secilenBoylam = 32.8597;
        _enlemController.text = '39.9334';
        _boylamController.text = '32.8597';
      });
      await _koordinattanAdreseGit(39.9334, 32.8597);
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _koordinattanAdreseGit(double lat, double lng) async {
    setState(() {
      _adresYukleniyor = true;
    });

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1&accept-language=en');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'SantiyeSefiApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        if (address != null) {
          final String? gelenUlke = address['country'];
          final bool turkiyeMi = gelenUlke != null &&
              (gelenUlke.toLowerCase() == 'türkiye' || 
               gelenUlke.toLowerCase() == 'turkey');

          if (turkiyeMi) {
            String? gelenIl = address['province'] ?? address['state'] ?? address['city'];
            String? gelenIlce = address['county'] ?? address['district'] ?? address['town'] ?? address['suburb'] ?? address['city_district'];
            
            setState(() {
              _secilenUlke = 'Türkiye';
              _ulkeController.text = 'Türkiye';
            });

            if (gelenIl != null) {
              gelenIl = gelenIl.replaceAll(' İli', '').replaceAll(' Province', '').trim();
              
              for (var il in _iller) {
                if (il.toLowerCase() == gelenIl!.toLowerCase()) {
                  gelenIl = il;
                  break;
                }
              }

              if (_iller.contains(gelenIl)) {
                setState(() {
                  _secilenIl = gelenIl;
                  _ilController.text = gelenIl!;
                  
                  final ilceListesi = _ilceler[gelenIl] ?? [];
                  _secilenIlce = null;
                  _ilceController.clear();
                  
                  if (gelenIlce != null) {
                    for (var ilce in ilceListesi) {
                      if (ilce.toLowerCase().contains(gelenIlce.toLowerCase()) ||
                          gelenIlce.toLowerCase().contains(ilce.toLowerCase())) {
                        _secilenIlce = ilce;
                        _ilceController.text = ilce;
                        break;
                      }
                    }
                  }
                  if (_secilenIlce == null && ilceListesi.isNotEmpty) {
                    _secilenIlce = ilceListesi.first;
                    _ilceController.text = ilceListesi.first;
                  }
                });
              }
            }
          } else {
            final String? gelenIl = address['state'] ?? address['province'] ?? address['region'] ?? address['county'];
            final String? gelenIlce = address['city'] ?? address['town'] ?? address['municipality'] ?? address['suburb'] ?? address['district'] ?? address['village'];
            
            setState(() {
              _secilenUlke = gelenUlke ?? 'Bilinmeyen Ülke';
              _ulkeController.text = _secilenUlke!;
              _secilenIl = gelenIl;
              _secilenIlce = gelenIlce;
              _ilController.text = gelenIl ?? '';
              _ilceController.text = gelenIlce ?? '';
            });
          }
        }
      }
    } catch (e) {
      print("Adres çözümleme hatası: $e");
    } finally {
      setState(() {
        _adresYukleniyor = false;
      });
    }
  }

  void _haritadanKonumSec() async {
    final LatLng baslangic = _secilenEnlem != null && _secilenBoylam != null
        ? LatLng(_secilenEnlem!, _secilenBoylam!)
        : const LatLng(39.9334, 32.8597);

    final (LatLng, double)? sonuc = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HaritaSecimScreen(
          baslangicKonum: baslangic,
          baslangicZoom: _sonZoom,
        ),
      ),
    );

    if (sonuc != null) {
      setState(() {
        _secilenEnlem = sonuc.$1.latitude;
        _secilenBoylam = sonuc.$1.longitude;
        _sonZoom = sonuc.$2;
        _enlemController.text = _secilenEnlem!.toStringAsFixed(6);
        _boylamController.text = _secilenBoylam!.toStringAsFixed(6);
      });
      await _koordinattanAdreseGit(_secilenEnlem!, _secilenBoylam!);
    }
  }

  void _koordinatlariGuncelle() async {
    final double? lat = double.tryParse(_enlemController.text);
    final double? lng = double.tryParse(_boylamController.text);
    if (lat != null && lng != null) {
      setState(() {
        _secilenEnlem = lat;
        _secilenBoylam = lng;
      });
      await _koordinattanAdreseGit(lat, lng);
    }
  }

  void _sonrakiAdimaGec() {
    if (_aktifAdim == 1) {
      if (_adController.text.isEmpty || _secilenIl == null || _secilenIlce == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen şantiye adı, il ve ilçe alanlarını doldurun.')),
        );
        return;
      }
      setState(() {
        _aktifAdim = 2;
      });
    } else if (_aktifAdim == 2) {
      if (_secilenSantiyeTuru == null || _kapasiteController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen şantiye türü ve kapasite bilgisini girin.')),
        );
        return;
      }
      setState(() {
        _aktifAdim = 3;
      });
    }
  }

  void _oncekiAdimaDon() {
    if (_aktifAdim > 1) {
      setState(() {
        _aktifAdim--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _oncekiAdimaDon,
                  ),
                  const Text('Yeni Şantiye',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StepDot(number: '1', label: 'Konum', active: _aktifAdim >= 1, current: _aktifAdim == 1),
                  Expanded(child: Container(height: 1, color: _aktifAdim >= 2 ? const Color(0xFF2563EB) : Colors.white24)),
                  _StepDot(number: '2', label: 'Bilgiler', active: _aktifAdim >= 2, current: _aktifAdim == 2),
                  Expanded(child: Container(height: 1, color: _aktifAdim >= 3 ? const Color(0xFF2563EB) : Colors.white24)),
                  _StepDot(number: '3', label: 'Tamamla', active: _aktifAdim >= 3, current: _aktifAdim == 3),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _aktifAdim == 1
                  ? _buildKonumAdimi()
                  : (_aktifAdim == 2 ? _buildBilgilerAdimi() : _buildTamamlamaAdimi()),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _aktifAdim == 3 ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şantiye başarıyla oluşturuldu! 🚀')),
                    );
                    Navigator.pop(context);
                  } : _sonrakiAdimaGec,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _aktifAdim == 3 ? 'Şantiyeyi Oluştur' : 'Devam Et',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonumAdimi() {
    final ilceListesi = _secilenIl != null ? (_ilceler[_secilenIl!] ?? []) : <String>[];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Şantiye Konum Bilgileri',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            if (_adresYukleniyor)
              const Row(
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)),
                  SizedBox(width: 8),
                  Text('Konum çözümleniyor...', style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Şantiye Adı *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _adController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration('Örn: Kurtuluş Konut Projesi veya 3MW GES'),
        ),

        const SizedBox(height: 16),
        const Text('Ülke *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        _secilenUlke == 'Türkiye'
            ? DropdownButtonFormField<String>(
                value: _secilenUlke,
                dropdownColor: cardBg,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Ülke seçiniz'),
                items: ulkeler.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) {
                  setState(() {
                    _secilenUlke = val;
                    _ulkeController.text = val ?? '';
                  });
                },
              )
            : TextField(
                controller: _ulkeController,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Ülke (otomatik doldu)'),
                onChanged: (val) {
                  _secilenUlke = val;
                },
              ),

        const SizedBox(height: 16),
        const Text('İl / Bölge *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        
        _secilenUlke == 'Türkiye'
            ? Autocomplete<String>(
                key: const ValueKey('il_turkiye'),
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) return _iller;
                  return _iller.where((il) => il.toLowerCase().contains(value.text.toLowerCase()));
                },
                onSelected: (selection) {
                  setState(() {
                    _secilenIl = selection;
                    _ilController.text = selection;
                    _secilenIlce = null;
                    _ilceController.clear();
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  if (controller.text != _ilController.text) {
                    controller.text = _ilController.text;
                  }
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: _fieldDecoration('İl ara veya haritadan seçin'),
                    onChanged: (val) {
                      setState(() {
                        _secilenIl = val;
                        _ilController.text = val;
                      });
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final il = options.elementAt(index);
                            return ListTile(
                              title: Text(il, style: const TextStyle(color: Colors.white)),
                              onTap: () => onSelected(il),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            : TextField(
                controller: _ilController,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('İl / eyalet / bölge'),
                onChanged: (val) {
                  _secilenIl = val;
                },
              ),

        const SizedBox(height: 16),
        const Text('İlçe *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),

        _secilenUlke == 'Türkiye'
            ? Autocomplete<String>(
                key: ValueKey('ilce_${_secilenIl}'),
                optionsBuilder: (TextEditingValue value) {
                  if (_secilenIl == null) return const [];
                  if (value.text.isEmpty) return ilceListesi;
                  return ilceListesi.where((ilce) => ilce.toLowerCase().contains(value.text.toLowerCase()));
                },
                onSelected: (selection) {
                  setState(() {
                    _secilenIlce = selection;
                    _ilceController.text = selection;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  if (controller.text != _ilceController.text && _ilceController.text.isNotEmpty) {
                    controller.text = _ilceController.text;
                  }
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: _secilenIl != null,
                    style: const TextStyle(color: Colors.white),
                    decoration: _fieldDecoration(_secilenIl == null ? 'Önce il seçin' : 'İlçe ara veya seçiniz'),
                    onChanged: (val) {
                      setState(() {
                        _secilenIlce = val;
                        _ilceController.text = val;
                      });
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final ilce = options.elementAt(index);
                            return ListTile(
                              title: Text(ilce, style: const TextStyle(color: Colors.white)),
                              onTap: () => onSelected(ilce),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            : TextField(
                controller: _ilceController,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('İlçe / şehir'),
                onChanged: (val) {
                  _secilenIlce = val;
                },
              ),

        const SizedBox(height: 20),

        // --- KÜÇÜK HARİTA ÖNİZLEME KUTUSU (HER YERİNDEN TIKLANABİLİR) ---
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _haritadanKonumSec,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (_secilenEnlem != null && _secilenBoylam != null)
                    AbsorbPointer(
                      child: FlutterMap(
                        key: ValueKey('kucuk_map_$_secilenEnlem-$_secilenBoylam'),
                        options: MapOptions(
                          initialCenter: LatLng(_secilenEnlem!, _secilenBoylam!),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.santiye_sefi',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_secilenEnlem!, _secilenBoylam!),
                                width: 60,
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 36),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),

                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2C4A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.white54, size: 20),
                            SizedBox(width: 10),
                            Text('Konumdan seç veya haritaya dokun', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Spacer(),
                            Icon(Icons.my_location, color: Colors.blueAccent, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        border: Border(top: BorderSide(color: Colors.blue.withOpacity(0.3))),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Konuma göre hava durumu otomatik olarak görüntülenecektir.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Veya Koordinatları Elle Girin', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _enlemController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Enlem (Lat)'),
                onChanged: (val) => _koordinatlariGuncelle(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _boylamController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Boylam (Lng)'),
                onChanged: (val) => _koordinatlariGuncelle(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBilgilerAdimi() {
    String kapasiteHint = 'Örn: 3 MW veya 15 MW';
    if (_secilenSantiyeTuru != null) {
      if (_secilenSantiyeTuru!.contains('Konut')) {
        kapasiteHint = 'Örn: 48 Daire / 3 Blok';
      } else if (_secilenSantiyeTuru!.contains('Altyapı')) {
        kapasiteHint = 'Örn: 12 km Yol';
      } else if (_secilenSantiyeTuru!.contains('Fabrika')) {
        kapasiteHint = 'Örn: 5000 m2 Kapalı Alan';
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Text('Proje Sınıflandırması & Kapasite',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text(
          'Seçilen koordinatlar hava durumu modülüyle eşleştirildi. Proje türü ve kapasite ise malzeme kritik stok eşiklerini belirleyecek.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 20),

        const Text('Şantiye Türü *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _secilenSantiyeTuru,
          dropdownColor: cardBg,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration('Şantiye türünü seçiniz (Örn: GES)'),
          items: _santiyeTurleri.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) => setState(() => _secilenSantiyeTuru = val),
        ),

        const SizedBox(height: 20),
        const Text('Kapasite / Ölçek *', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: _kapasiteController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(kapasiteHint),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTamamlamaAdimi() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Text('Şantiye Özeti',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ozetSatir('Şantiye Adı:', _adController.text),
              const Divider(color: Colors.white10, height: 20),
              _ozetSatir('Ülke:', _secilenUlke ?? '-'),
              const Divider(color: Colors.white10, height: 20),
              _ozetSatir('Konum (İl/İlçe):', '${_secilenIlce ?? ''} / ${_secilenIl ?? ''}'),
              const Divider(color: Colors.white10, height: 20),
              _ozetSatir('Koordinat (Hava Durumu İçin):', _secilenEnlem != null ? '${_secilenEnlem!.toStringAsFixed(4)}, ${_secilenBoylam!.toStringAsFixed(4)}' : 'Girilmedi'),
              const Divider(color: Colors.white10, height: 20),
              _ozetSatir('Şantiye Türü:', _secilenSantiyeTuru ?? '-'),
              const Divider(color: Colors.white10, height: 20),
              _ozetSatir('Kapasite:', _kapasiteController.text),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _ozetSatir(String baslik, String deger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// --- TAM EKRAN HARİTA SEÇİM EKRANI ---
class HaritaSecimScreen extends StatefulWidget {
  final LatLng baslangicKonum;
  final double baslangicZoom;
  const HaritaSecimScreen({super.key, required this.baslangicKonum, required this.baslangicZoom});

  @override
  State<HaritaSecimScreen> createState() => _HaritaSecimScreenState();
}

class _HaritaSecimScreenState extends State<HaritaSecimScreen> {
  late final MapController _mapController;
  late LatLng _secilenKonum;
  late double _aktifZoom;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _secilenKonum = widget.baslangicKonum;
    _aktifZoom = widget.baslangicZoom;
  }

  Future<void> _anlikKonumumaGit() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng yeniYer = LatLng(position.latitude, position.longitude);
      setState(() {
        _secilenKonum = yeniYer;
        _aktifZoom = 15.0;
      });
      _mapController.move(yeniYer, 15.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şantiye Konumunu Seç', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF12213A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _secilenKonum,
              initialZoom: _aktifZoom,
              onPositionChanged: (camera, hasGesture) {
                if (camera.center != null && camera.zoom != null) {
                  setState(() {
                    _secilenKonum = camera.center!;
                    _aktifZoom = camera.zoom!;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.santiye_sefi',
              ),
            ],
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.location_on, size: 45, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1B2C4A),
              mini: true,
              onPressed: _anlikKonumumaGit, // Düzeltildi (_git)
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context, (_secilenKonum, _aktifZoom));
                },
                child: const Text('Bu Konumu Seç', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String number;
  final String label;
  final bool active;
  final bool current;
  const _StepDot({required this.number, required this.label, required this.active, required this.current});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2563EB) : Colors.white24;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: current ? Colors.white : Colors.white38, fontSize: 11, fontWeight: current ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}