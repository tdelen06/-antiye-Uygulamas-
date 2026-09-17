import 'package:flutter/material.dart';

class MalzemeScreen extends StatefulWidget {
  const MalzemeScreen({super.key});

  @override
  State<MalzemeScreen> createState() => _MalzemeScreenState();
}

class _MalzemeScreenState extends State<MalzemeScreen> {
  final List<Map<String, dynamic>> _malzemeListesi = [
    {'ad': 'CEM I 42.5 Çimento', 'miktar': 320.0, 'kritik': 100.0, 'birim': 'Torba'},
    {'ad': 'Ø12 İnşaat Demiri', 'miktar': 14.0, 'kritik': 20.0, 'birim': 'Ton'},
    {'ad': 'Tuğla (13.5)', 'miktar': 4500.0, 'kritik': 1000.0, 'birim': 'Adet'},
  ];

  void _malzemeFormModal(BuildContext context, {int? index, Map<String, dynamic>? mevcutMalzeme}) {
    final bool duzenlemeModu = index != null && mevcutMalzeme != null;

    final adController = TextEditingController(text: duzenlemeModu ? mevcutMalzeme['ad'] : '');
    final miktarController = TextEditingController(text: duzenlemeModu ? mevcutMalzeme['miktar'].toString() : '');
    final kritikController = TextEditingController(text: duzenlemeModu ? mevcutMalzeme['kritik'].toString() : '50');
    final birimController = TextEditingController(text: duzenlemeModu ? mevcutMalzeme['birim'] : 'Adet');

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
                duzenlemeModu ? 'Malzeme / Stok Düzenle' : 'Yeni Malzeme Ekle',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Malzeme Adı',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: miktarController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Mevcut Miktar',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: kritikController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Kritik Eşik Sınırı',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: birimController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Birim (Torba, Ton, Adet vb.)',
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
                    if (adController.text.isNotEmpty && miktarController.text.isNotEmpty) {
                      final miktar = double.tryParse(miktarController.text) ?? 0.0;
                      final kritik = double.tryParse(kritikController.text) ?? 10.0;
                      setState(() {
                        if (duzenlemeModu) {
                          _malzemeListesi[index] = {
                            'ad': adController.text,
                            'miktar': miktar,
                            'kritik': kritik,
                            'birim': birimController.text,
                          };
                        } else {
                          _malzemeListesi.add({
                            'ad': adController.text,
                            'miktar': miktar,
                            'kritik': kritik,
                            'birim': birimController.text,
                          });
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(duzenlemeModu ? 'Değişiklikleri Kaydet' : 'Stoklara Ekle',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
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
        title: const Text('Şantiye Malzeme & Kritik Stok', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () => _malzemeFormModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _malzemeListesi.length,
        itemBuilder: (context, index) {
          final malzeme = _malzemeListesi[index];
          final double miktar = malzeme['miktar'];
          final double kritik = malzeme['kritik'];
          
          final bool kritikMi = miktar <= kritik;
          final String durum = kritikMi ? 'Kritik Az' : 'Yeterli';
          final Color durumRengi = kritikMi ? Colors.red : Colors.green;

          return Dismissible(
            key: Key(malzeme['ad']! + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _malzemeListesi.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${malzeme['ad']} stoktan çıkarıldı')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(malzeme['ad'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Miktar: $miktar ${malzeme['birim']} (Kritik Sınır: $kritik)', 
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: durumRengi.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(durum, style: TextStyle(color: durumRengi, fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  // Sadece kaleme tıklandığında düzenleme açılır
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                    onPressed: () => _malzemeFormModal(context, index: index, mevcutMalzeme: malzeme),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _malzemeFormModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}