import 'package:flutter/material.dart';
import 'yeni_santiye_screen.dart';
import 'hava_durumu_screen.dart';
import 'personel_screen.dart';
import 'malzeme_screen.dart';
import 'arac_gerec_screen.dart';
import 'is_takibi_screen.dart';
import 'takvim_screen.dart';
import 'istatistik_screen.dart';
import 'gunluk_rapor_screen.dart';
import 'santiye_drawer.dart'; 
import 'santiye_kadrosu_screen.dart';
import 'harita_parsel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Aktif şantiye state'i
  Map<String, String> aktifSantiye = {
    'ad': 'Kurtuluş Konut Projesi',
    'konum': 'Ankara / Keçiören',
    'hava': '18°C, Parçalı Bulutlu',
    'personel': '24 Personel',
    'durum': 'Aktif / Devam Ediyor',
  };

  // Alt menüden geçilecek ekranların listesi
  late final List<Widget> _screens = [
    _buildAnaSayfaIcerigi(), // 0. İndeks: Ana Sayfa İçeriği
    const TakvimScreen(),   // 1. İndeks: Takvim
    const IstatistikScreen(), // 2. İndeks: Bütçe/İstatistik
  ];

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    return Scaffold(
      backgroundColor: bg,
      
      // Sol üstteki üç çizgi ile açılan şantiye yönetim çekmecesi
      drawer: SantiyeYonetimDrawer(
        onSantiyeSecildi: (secilenSantiye) {
          setState(() {
            aktifSantiye = secilenSantiye;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aktif Proje Değiştirildi: ${secilenSantiye['ad']} 🏗️')),
          );
        },
      ),

      // Sağ alttaki 3 noktanın tetiklediği genel kadro/yönetim paneli
      endDrawer: const SantiyeKadrosuScreen(),

      body: _screens[_currentIndex],

      // Alt Menü Çubuğu
      bottomNavigationBar: BottomAppBar(
        color: cardBg,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.home, color: _currentIndex == 0 ? Colors.blueAccent : Colors.white54),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.calendar_today_outlined, color: _currentIndex == 1 ? Colors.blueAccent : Colors.white54),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 40), // FAB boşluğu
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.bar_chart_outlined, color: _currentIndex == 2 ? Colors.blueAccent : Colors.white54),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
              // Sağ alttaki 3 nokta: Şantiye Kadrosu / Yönetim Paneli Açar
              Builder(
                builder: (ctx) => IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz, color: Colors.white54),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),

      // Ortadaki Artı (+) Hızlı İşlem Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const YeniSantiyeScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ==========================================
  // HESAP VE GÜVENLİK AYARLARI MENÜSÜ (Sağ Üst Profil Butonu)
  // ==========================================
  void _hesapAyarlariniGoster(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2C4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tunahan Delen', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Elektrik-Elektronik Mühendisi / Şantiye Şefi', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: Colors.white70),
                title: const Text('Unvan ve Profil Bilgileri', style: TextStyle(color: Colors.white, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.white70),
                title: const Text('Güvenlik ve Şifre Değiştir', style: TextStyle(color: Colors.white, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: const Text('Oturumu Kapat', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ANA SAYFA GÖRÜNÜMÜ (0. İndeks)
  // ==========================================
  Widget _buildAnaSayfaIcerigi() {
    const cardBg = Color(0xFF1B2C4A);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 4),
                Text(aktifSantiye['ad']!,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white),
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // SAĞ ÜST PROFİL İKONU (Tıklanabilir hale getirildi)
                GestureDetector(
                  onTap: () => _hesapAyarlariniGoster(context),
                  child: const CircleAvatar(
                    radius: 16, 
                    backgroundColor: Colors.white24, 
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(aktifSantiye['ad']!,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.edit, color: Colors.white, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(aktifSantiye['konum']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Harita & Parsel Kartı (ListView içine eklenebilir)
GestureDetector(
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HaritaParselScreen())),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.amberAccent.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.map_outlined, color: Colors.amberAccent, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Şantiye Haritası & Parsel Sınırları', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Ada/Parsel kontrolü, uydu ve GPS konum takibi', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
      ],
    ),
  ),
),
const SizedBox(height: 16),
                // Hava Durumu Kartı
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HavaDurumuScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_cloudy, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        const Text('18°C', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('H: 22°    L: 12°', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('Parçalı Bulutlu', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.air, color: Colors.white54, size: 16),
                        const SizedBox(width: 4),
                        const Text('12 km/s', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Günlük Rapor Kartı
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GunlukRaporScreen(santiyeTuru: 'GES (Güneş Enerji Santrali)'))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_turned_in, color: Colors.blueAccent, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Günlük Saha Raporu & Aşamalar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text('TEDAŞ Kabul Aşamaları ve Fotoğraf Doğrulama', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // İstatistik Kartları
                Row(
                  children: [
                    _StatCard(icon: Icons.people_outline, value: '24', total: '/32', label: 'Personel', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonelScreen()))),
                    const SizedBox(width: 10),
                    _StatCard(icon: Icons.inventory_2_outlined, value: '12', total: '/45', label: 'Malzeme', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MalzemeScreen()))),
                    const SizedBox(width: 10),
                    _StatCard(icon: Icons.local_shipping_outlined, value: '3', total: '/8', label: 'Araç/Gereç', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AracGerecScreen()))),
                    const SizedBox(width: 10),
                    _StatCard(icon: Icons.checklist_outlined, value: '5', total: '/12', label: 'İş Takibi', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IsTakibiScreen()))),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: const [
                    Text('Bugünün İşleri', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    Spacer(),
                    Text('Tümünü Gör', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                const _TaskTile(color: Colors.green, title: 'Beton dökümü', time: '08:00 - 12:00', status: 'Tamamlandı', statusColor: Colors.green),
                const _TaskTile(color: Colors.blue, title: 'Elektrik pano montajı', time: '13:00 - 17:00', status: 'Devam Ediyor', statusColor: Colors.blue),
                const _TaskTile(color: Colors.orange, title: 'Malzeme sevkiyatı', time: '15:00 - 16:00', status: 'Beklemede', statusColor: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String total;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({required this.icon, required this.value, required this.total, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(color: const Color(0xFF1B2C4A), borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    TextSpan(text: total, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Color color;
  final String title;
  final String time;
  final String status;
  final Color statusColor;

  const _TaskTile({required this.color, required this.title, required this.time, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1B2C4A), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}