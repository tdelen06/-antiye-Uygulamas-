import 'package:flutter/material.dart';

class PersonelScreen extends StatefulWidget {
  const PersonelScreen({super.key});

  @override
  State<PersonelScreen> createState() => _PersonelScreenState();
}

class _PersonelScreenState extends State<PersonelScreen> {
  final List<Map<String, String>> _personelListesi = [
    {'ad': 'Ahmet Yılmaz', 'gorev': 'Kalıpçı Usta', 'tel': '0532 111 2233', 'durum': 'Aktif'},
    {'ad': 'Mehmet Demir', 'gorev': 'Demirci', 'tel': '0533 222 3344', 'durum': 'Aktif'},
    {'ad': 'Caner Korkmaz', 'gorev': 'Elektrikçi', 'tel': '0535 333 4455', 'durum': 'İzinde'},
    {'ad': 'Murat Şahin', 'gorev': 'Kepçe Operatörü', 'tel': '0536 444 5566', 'durum': 'Aktif'},
  ];

  // Ekleme veya Düzenleme için Ortak Modal
  void _personelFormModal(BuildContext context, {int? index, Map<String, String>? mevcutPersonel}) {
    final bool duzenlemeModu = index != null && mevcutPersonel != null;

    final adController = TextEditingController(text: duzenlemeModu ? mevcutPersonel['ad'] : '');
    final gorevController = TextEditingController(text: duzenlemeModu ? mevcutPersonel['gorev'] : '');
    final telController = TextEditingController(text: duzenlemeModu ? mevcutPersonel['tel'] : '');
    String secilenDurum = duzenlemeModu ? (mevcutPersonel['durum'] ?? 'Aktif') : 'Aktif';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2C4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    duzenlemeModu ? 'Personel Bilgilerini Düzenle' : 'Yeni Personel Ekle',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: adController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: gorevController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Görevi / Unvanı',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: secilenDurum,
                    dropdownColor: const Color(0xFF1B2C4A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Çalışma Durumu',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                    items: ['Aktif', 'İzinde', 'Ayrıldı'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setModalState(() {
                        secilenDurum = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      onPressed: () {
                        if (adController.text.isNotEmpty && gorevController.text.isNotEmpty) {
                          setState(() {
                            if (duzenlemeModu) {
                              _personelListesi[index] = {
                                'ad': adController.text,
                                'gorev': gorevController.text,
                                'tel': telController.text.isEmpty ? '-' : telController.text,
                                'durum': secilenDurum,
                              };
                            } else {
                              _personelListesi.add({
                                'ad': adController.text,
                                'gorev': gorevController.text,
                                'tel': telController.text.isEmpty ? '-' : telController.text,
                                'durum': secilenDurum,
                              });
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(duzenlemeModu ? 'Değişiklikleri Kaydet' : 'Kaydet ve Ekle',
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
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
        title: const Text('Şantiye Personel Listesi', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _personelFormModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _personelListesi.length,
        itemBuilder: (context, index) {
          final personel = _personelListesi[index];
          final bool aktif = personel['durum'] == 'Aktif';

          return Dismissible(
            key: Key(personel['ad']! + index.toString()),
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
                _personelListesi.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${personel['ad']} listeden çıkarıldı')),
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
                  CircleAvatar(
                    backgroundColor: Colors.white12,
                    child: Text(
                      personel['ad']![0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(personel['ad']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${personel['gorev']} • ${personel['tel']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (aktif ? Colors.green : Colors.orange).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      personel['durum']!,
                      style: TextStyle(color: aktif ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sadece kaleme tıklandığında açılır (Yanlışlıkla tıklama riski sıfır)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                    onPressed: () => _personelFormModal(context, index: index, mevcutPersonel: personel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _personelFormModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}