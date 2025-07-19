import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dashboard.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = true;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        namaController.text = profile['username'] ?? '';
        emailController.text = user.email ?? '';
      }
    } catch (e) {
      _showFlushbar('Gagal memuat profil: $e', success: false);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final newNama = namaController.text.trim();
    final newPassword = passwordController.text.trim();

    if (newNama.isEmpty) {
      _showFlushbar('Nama tidak boleh kosong', success: false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.from('profiles').update({
        'username': newNama,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (newPassword.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }

      _showFlushbar('Profil berhasil diperbarui', success: true);
    } catch (e) {
      _showFlushbar('Gagal menyimpan profil: $e', success: false);
    }

    setState(() {
      isLoading = false;
      passwordController.clear();
    });
  }

  void _showFlushbar(String message, {bool success = true}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: success ? Colors.green : Colors.redAccent,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
    ).show(context);
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yakin'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SolidBackground(),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40),
                        child: Column(
                          children: [
                            const Text(
                              'Profilku',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Icon(Icons.account_circle,
                                size: 80, color: Color.fromARGB(255, 55, 134, 115)),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: namaController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person),
                                      labelText: 'Nama',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: emailController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.email),
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock),
                                      labelText: 'Password baru (opsional)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      'Simpan',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: logout,
                              icon: const Icon(Icons.logout,
                                  color: Colors.redAccent),
                              label: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedItemColor: const Color.fromARGB(255, 50, 170, 144),
        unselectedItemColor: const Color.fromARGB(179, 98, 207, 184),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}


class SolidBackground extends StatelessWidget {
  const SolidBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB2FEFA), 
      width: double.infinity,
      height: double.infinity,
    );
  }
}
