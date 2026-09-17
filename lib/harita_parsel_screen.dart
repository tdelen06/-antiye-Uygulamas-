import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';

class HaritaParselScreen extends StatefulWidget {
  const HaritaParselScreen({Key? key}) : super(key: key);

  @override
  State<HaritaParselScreen> createState() => _HaritaParselScreenState();
}

class _HaritaParselScreenState extends State<HaritaParselScreen> with SingleTickerProviderStateMixin {
  bool uyduModu = false;
  bool parselGoster = true;

  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();

  final LatLng _santiyeMerkez = const LatLng(39.9512, 32.6421);
  LatLng? _anlikKonum;
  bool _parselIcindeMi = false;

  late AnimationController _animasyonController;

  final List<LatLng> _parselKozelleri = [
    const LatLng(39.9520, 32.6410),
    const LatLng(39.9520, 32.6432),
    const LatLng(39.9504, 32.6432),
    const LatLng(39.9504, 32.6410),
  ];

  Map<String, dynamic>? _tasinanPin;

  String _aktifBlok = 'A Blok';
  final List<String> _blokListesi = ['A Blok', 'B Blok', 'C Blok'];
  
  // Katları saf tamsayılar olarak tutuyoruz
  final List<int> _katListesi = [-1, 0, 1, 2];
  
  // Her katın özel ismini tutan harita
  final Map<int, String> _katOzelIsimleri = {
    -1: 'Otopark',
    0: 'Zemin Giriş',
    1: '1. Normal Kat',
    2: '2. Normal Kat',
  };

  int _aktifKat = 0;

  final List<Color> _anaRenkler = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.amberAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.cyanAccent,
  ];

  final List<Map<String, dynamic>> _eklenenPinler = [
    {
      'id': '1',
      'baslik': 'Ana Pano Yeri',
      'koordinat': const LatLng(39.9512, 32.6421),
      'not': 'Zemin kat ana elektrik panosu montaj alanı.',
      'renk': Colors.redAccent,
      'fotograf': null,
      'blok': 'A Blok',
      'kat': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animasyonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    _konumIzniVeTakibiBaslat();
  }

  @override
  void dispose() {
    _animasyonController.dispose();
    super.dispose();
  }

  String _katAdiGetir(int katNumarasi) {
    if (_katOzelIsimleri.containsKey(katNumarasi) && _katOzelIsimleri[katNumarasi]!.trim().isNotEmpty) {
      return _katOzelIsimleri[katNumarasi]!;
    }
    if (katNumarasi == 0) return 'Zemin Kat';
    if (katNumarasi < 0) return '${katNumarasi.abs()}. Bodrum';
    return 'Kat $katNumarasi';
  }

  void _katSirala() {
    _katListesi.sort((a, b) => a.compareTo(b));
  }

  // Yeni Blok Ekleme Dialogu
  void _yeniBlokEkleDialogGoster(BuildContext context) {
    final TextEditingController blokController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Yeni Blok Ekle', style: TextStyle(color: Colors.amberAccent, fontSize: 14)),
        content: TextField(
          controller: blokController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Blok Adı (Örn: D Blok, Villa 1)',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              String yeniBlok = blokController.text.trim();
              if (yeniBlok.isNotEmpty) {
                if (_blokListesi.contains(yeniBlok)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Bu blok zaten mevcut!')),
                  );
                  return;
                }
                setState(() {
                  _blokListesi.add(yeniBlok);
                  _aktifBlok = yeniBlok;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Yeni blok eklendi: $yeniBlok 🏗️')),
                );
              }
            },
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Blok Adını Düzenleme Dialogu
  void _blokIsminiDuzenleDialogGoster(BuildContext context) {
    final TextEditingController blokDuzenleController = TextEditingController(text: _aktifBlok);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Blok Adını Düzenle', style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
        content: TextField(
          controller: blokDuzenleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Yeni Blok Adı',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              String yeniAd = blokDuzenleController.text.trim();
              if (yeniAd.isNotEmpty && yeniAd != _aktifBlok) {
                if (_blokListesi.contains(yeniAd)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Bu blok adı zaten mevcut!')),
                  );
                  return;
                }
                setState(() {
                  int index = _blokListesi.indexOf(_aktifBlok);
                  if (index != -1) {
                    _blokListesi[index] = yeniAd;
                  }
                  for (var pin in _eklenenPinler) {
                    if (pin['blok'] == _aktifBlok) {
                      pin['blok'] = yeniAd;
                    }
                  }
                  _aktifBlok = yeniAd;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blok adı güncellendi ✏️')),
                );
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Blok Silme Fonksiyonu
  void _blokSil() {
    if (_blokListesi.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Son blok silinemez!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('$_aktifBlok silinsin mi?', style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        content: const Text('Bu bloğa ait tüm katlar ve işaretlenen noktalar kaldırılacaktır.', style: TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                String silinenBlok = _aktifBlok;
                _blokListesi.remove(silinenBlok);
                _eklenenPinler.removeWhere((p) => p['blok'] == silinenBlok);
                _aktifBlok = _blokListesi.first;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blok silindi 🗑️')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _yeniKatEkleDialogGoster(BuildContext context) {
    final TextEditingController yeniKatController = TextEditingController();
    final TextEditingController katIsimController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Yeni Kat / Seviye Ekle', style: TextStyle(color: Colors.amberAccent, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: yeniKatController,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kat Numarası (Sayısal, Örn: 3 veya -2)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: katIsimController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kat Adı / Açıklaması (İsteğe bağlı)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Örn: Sığınak, Asma Kat',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              if (yeniKatController.text.isNotEmpty && yeniKatController.text != '-') {
                int girilenKat = int.parse(yeniKatController.text);
                
                if (_katListesi.contains(girilenKat)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Bu kat numarası zaten listede mevcut!')),
                  );
                  return;
                }

                int enYuksekKat = _katListesi.where((k) => k > 0).fold(0, (a, b) => math.max(a, b));
                int enDusukKat = _katListesi.where((k) => k < 0).fold(0, (a, b) => math.min(a, b));

                if (girilenKat > 0 && girilenKat != enYuksekKat + 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('⚠️ Önce Kat ${enYuksekKat + 1} eklenmelidir!')),
                  );
                  return;
                }

                if (girilenKat < 0 && girilenKat != enDusukKat - 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('⚠️ Önce ${enDusukKat.abs() + 1}. Bodrum eklenmelidir!')),
                  );
                  return;
                }

                setState(() {
                  _katListesi.add(girilenKat);
                  _katSirala();
                  if (katIsimController.text.trim().isNotEmpty) {
                    _katOzelIsimleri[girilenKat] = katIsimController.text.trim();
                  } else {
                    _katOzelIsimleri[girilenKat] = girilenKat < 0 ? '${girilenKat.abs()}. Bodrum' : 'Kat $girilenKat';
                  }
                  _aktifKat = girilenKat;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Yeni seviye eklendi: ${_katAdiGetir(_aktifKat)} 🏢')),
                );
              }
            },
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _katSil() {
    if (_katListesi.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Son kat silinemez!')),
      );
      return;
    }

    int enYuksekKat = _katListesi.where((k) => k > 0).fold(0, (a, b) => math.max(a, b));
    int enDusukKat = _katListesi.where((k) => k < 0).fold(0, (a, b) => math.min(a, b));

    if (_aktifKat == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Zemin kat (0) silinemez!')),
      );
      return;
    }

    if (_aktifKat != enYuksekKat && _aktifKat != enDusukKat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Sıralı yapıyı bozmamak için önce en üstteki katı veya en alttaki bodrumu silmelisiniz!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('${_katAdiGetir(_aktifKat)} silinsin mi?', style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        content: const Text('Bu kata ait işaretlenmiş noktalar da kaldırılacaktır.', style: TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                int silinenKat = _aktifKat;
                _katListesi.remove(silinenKat);
                _katOzelIsimleri.remove(silinenKat);
                _eklenenPinler.removeWhere((p) => p['kat'] == silinenKat);
                _aktifKat = _katListesi.contains(0) ? 0 : _katListesi.last;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kat silindi 🗑️')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _katIsminiDuzenleDialogGoster(BuildContext context) {
    final TextEditingController isimDuzenleController = TextEditingController(text: _katOzelIsimleri[_aktifKat] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Kat Adını Düzenle', style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
        content: TextField(
          controller: isimDuzenleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Yeni Kat Adı',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              setState(() {
                _katOzelIsimleri[_aktifKat] = isimDuzenleController.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kat adı güncellendi ✏️')),
              );
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool _noktaParselIcindeMi(LatLng nokta, List<LatLng> poligon) {
    int intersectCount = 0;
    for (int i = 0; i < poligon.length; i++) {
      LatLng p1 = poligon[i];
      LatLng p2 = poligon[(i + 1) % poligon.length];

      if (((p1.latitude > nokta.latitude) != (p2.latitude > nokta.latitude)) &&
          (nokta.longitude < (p2.longitude - p1.longitude) * (nokta.latitude - p1.latitude) / (p2.latitude - p1.latitude) + p1.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2 == 1);
  }

  Future<void> _konumIzniVeTakibiBaslat() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      if (mounted) {
        setState(() {
          _anlikKonum = LatLng(position.latitude, position.longitude);
          _parselIcindeMi = _noktaParselIcindeMi(_anlikKonum!, _parselKozelleri);
        });
      }
    } catch (_) {}

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted) {
        LatLng yeniKonum = LatLng(position.latitude, position.longitude);
        setState(() {
          _anlikKonum = yeniKonum;
          _parselIcindeMi = _noktaParselIcindeMi(yeniKonum, _parselKozelleri);
        });
      }
    });
  }

  Future<void> _cadVerisiIceAktar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dxf', 'json', 'txt', 'csv'],
    );

    if (result != null) {
      setState(() {
        _eklenenPinler.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'baslik': 'CAD İçe Aktarılan Nokta',
          'koordinat': const LatLng(39.9515, 32.6425),
          'not': 'AutoCAD projesinden çekildi (${result.files.single.name})',
          'renk': Colors.cyanAccent,
          'fotograf': null,
          'blok': _aktifBlok,
          'kat': _aktifKat,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CAD dosyası okundu: ${result.files.single.name} 📐')),
      );
    }
  }

  Future<String?> _fotografSec(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    return image?.path;
  }

  void _noktaEkleDialogGoster(BuildContext context) {
    final TextEditingController baslikController = TextEditingController();
    final TextEditingController notController = TextEditingController();
    
    Color secilenRenk = Colors.redAccent;
    String dialogBlok = _aktifBlok;
    int dialogKat = _aktifKat;
    String? geciciFotograf;
    LatLng yeniPinKonum = _mapController.camera.center;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2C4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 Şantiyeye Yeni Nokta Ekle',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baslikController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nokta Başlığı (Örn: Kolon Filizi, Pano)',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Blok:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: dialogBlok,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    items: _blokListesi.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                                    onChanged: (val) => setStateModal(() => dialogBlok = val!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kat / Seviye:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: dialogKat,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                    items: _katListesi.map((k) => DropdownMenuItem(value: k, child: Text(_katAdiGetir(k), overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (val) => setStateModal(() => dialogKat = val!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Açıklama / Not',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                          icon: const Icon(Icons.camera_alt, color: Colors.blueAccent, size: 16),
                          label: const Text('Fotoğraf Ekle', style: TextStyle(color: Colors.white, fontSize: 11)),
                          onPressed: () async {
                            String? yol = await _fotografSec(ImageSource.camera);
                            if (yol != null) setStateModal(() => geciciFotograf = yol);
                          },
                        ),
                        const SizedBox(width: 10),
                        if (geciciFotograf != null)
                          const Text('✅ Fotoğraf Eklendi', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Pin Rengi:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _anaRenkler.map((renk) {
                        bool secili = secilenRenk == renk;
                        return GestureDetector(
                          onTap: () => setStateModal(() => secilenRenk = renk),
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: renk,
                              shape: BoxShape.circle,
                              border: Border.all(color: secili ? Colors.white : Colors.transparent, width: 3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal', style: TextStyle(color: Colors.white54)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          onPressed: () {
                            if (baslikController.text.isNotEmpty) {
                              setState(() {
                                _eklenenPinler.add({
                                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                                  'baslik': baslikController.text,
                                  'koordinat': yeniPinKonum,
                                  'not': notController.text,
                                  'renk': secilenRenk,
                                  'fotograf': geciciFotograf,
                                  'blok': dialogBlok,
                                  'kat': dialogKat,
                                });
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Yeni nokta başarıyla eklendi 🎯')),
                              );
                            }
                          },
                          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pinDetayGoster(Map<String, dynamic> pin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pin['baslik'],
                      style: TextStyle(color: pin['renk'], fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text('${pin['blok']} - ${_katAdiGetir(pin['kat'])}', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
              const SizedBox(height: 8),
              Text(pin['not'].isNotEmpty ? pin['not'] : 'Not eklenmemiş.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              if (pin['fotograf'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(pin['fotograf']), height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Sil'),
                    onPressed: () {
                      setState(() => _eklenenPinler.remove(pin));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pin silindi 🗑️')));
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: pin['renk']),
                    icon: const Icon(Icons.open_with, color: Colors.white, size: 16),
                    label: const Text('Taşı', style: TextStyle(color: Colors.white, fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _tasinanPin = pin);
                      _mapController.move(pin['koordinat'], _mapController.camera.zoom);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1E293B);

    final filtrelenmisPinler = _eklenenPinler.where((pin) {
      return pin['blok'] == _aktifBlok && pin['kat'] == _aktifKat;
    }).toList();

    List<Marker> olusturulanMarkerlar = [];
    
    for (var pin in filtrelenmisPinler) {
      if (_tasinanPin != null && _tasinanPin!['id'] == pin['id']) continue;

      olusturulanMarkerlar.add(
        Marker(
          point: pin['koordinat'],
          width: 90, height: 90,
          child: GestureDetector(
            onTap: () => _pinDetayGoster(pin),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: pin['renk'], width: 1.5),
                  ),
                  child: Text(
                    pin['baslik'],
                    style: TextStyle(color: pin['renk'], fontSize: 8, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.location_pin, color: pin['renk'], size: 36),
              ],
            ),
          ),
        ),
      );
    }

    if (_anlikKonum != null) {
      olusturulanMarkerlar.add(
        Marker(
          point: _anlikKonum!,
          width: 80, height: 80,
          child: AnimatedBuilder(
            animation: _animasyonController,
            builder: (context, child) {
              double aci = math.sin(_animasyonController.value * 2 * math.pi) * 0.15;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _parselIcindeMi ? Colors.green.shade800 : Colors.red.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _parselIcindeMi ? 'Parsel İçi' : 'Parsel Dışı',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Transform.rotate(
                    angle: aci,
                    child: const Icon(
                      Icons.accessibility_new,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: const Text('Şantiye Saha Yönetimi', style: TextStyle(color: Colors.white, fontSize: 14)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.amberAccent),
            tooltip: 'CAD Dosyası İçe Aktar',
            onPressed: _cadVerisiIceAktar,
          ),
          IconButton(
            icon: Icon(uyduModu ? Icons.layers : Icons.map, color: Colors.blueAccent),
            onPressed: () => setState(() => uyduModu = !uyduModu),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _santiyeMerkez, initialZoom: 16.5),
            children: [
              TileLayer(
                urlTemplate: uyduModu
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (parselGoster)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _parselKozelleri,
                      color: Colors.amberAccent.withOpacity(0.2),
                      borderColor: Colors.amberAccent,
                      borderStrokeWidth: 3.0,
                    ),
                  ],
                ),
              MarkerLayer(markers: olusturulanMarkerlar),
            ],
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BLOK KISMI
                  Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      const Text('Blok:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _aktifBlok,
                            dropdownColor: cardBg,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            items: _blokListesi.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (val) => setState(() => _aktifBlok = val!),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _blokIsminiDuzenleDialogGoster(context),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.edit, color: Colors.cyanAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: _blokSil,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.delete_sweep, color: Colors.redAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _yeniBlokEkleDialogGoster(context),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.add_box, color: Colors.greenAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  // KAT KISMI (Düzenlendi: onPressed yerine onTap kullanıldı)
                  Row(
                    children: [
                      const Icon(Icons.layers, color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 6),
                      const Text('Kat:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _aktifKat,
                            dropdownColor: cardBg,
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            items: _katListesi.map((k) => DropdownMenuItem(value: k, child: Text(_katAdiGetir(k), overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) => setState(() => _aktifKat = val!),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _katIsminiDuzenleDialogGoster(context),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.edit, color: Colors.cyanAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: _katSil,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.delete_sweep, color: Colors.redAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _yeniKatEkleDialogGoster(context),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.add_circle, color: Colors.greenAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_tasinanPin != null)
            Positioned(
              top: 120,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.amber.shade900.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pin Taşıma Modu Aktif', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      onPressed: () {
                        setState(() {
                          _tasinanPin!['koordinat'] = _mapController.camera.center;
                          _tasinanPin = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pin yeni yerine taşındı 🎯')));
                      },
                      child: const Text('Kaydet', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.extended(
                  backgroundColor: cardBg,
                  icon: const Icon(Icons.add_location_alt, color: Colors.amberAccent),
                  label: const Text('Nokta Ekle', style: TextStyle(color: Colors.white)),
                  onPressed: () => _noktaEkleDialogGoster(context),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.blueAccent,
                  tooltip: 'Şantiye Merkezine Git',
                  child: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _mapController.move(_santiyeMerkez, 17.5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şantiye merkezine odaklanıldı 🏗️')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}