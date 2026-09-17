import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; 
  String secilenRol = 'Elektrik Mühendisi';
  
  final List<String> roller = [
    'Patron / CEO',
    'Proje Müdürü',
    'Elektrik Mühendisi',
    'Makine Mühendisi',
  ];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _odaNoController = TextEditingController();
  final TextEditingController _odaSifreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF12213A);
    const cardBg = Color(0xFF1B2C4A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.security, color: Colors.blueAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    isLogin ? 'Şantiye Odası Girişi' : 'Teknik Kadro Kaydı',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin ? 'Güvenli şantiye odanıza bağlanın' : 'Yetkili ekibe katılmak için bilgileri doldurun',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Kurumsal E-posta', Icons.email_outlined),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _sifreController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Şifre', Icons.lock_outline),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12213A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: secilenRol,
                        dropdownColor: const Color(0xFF12213A),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        items: roller.map((rol) {
                          return DropdownMenuItem(
                            value: rol,
                            child: Text(rol),
                          );
                        }).toList(),
                        onChanged: (yeniRol) {
                          setState(() {
                            secilenRol = yeniRol!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _odaNoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Şantiye Oda Numarası (Örn: #SR-8492)', Icons.meeting_room_outlined),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _odaSifreController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Oda Güvenlik Şifresi', Icons.vpn_key_outlined),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                      );
                    },
                    child: Text(
                      isLogin ? 'Odaya Bağlan' : 'Kayıt Ol ve Oda Kur/Katıl',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin ? 'Hesabınız yok mu? Kayıt olun' : 'Zaten hesabınız var mı? Giriş yapın',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true,
      fillColor: const Color(0xFF12213A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}