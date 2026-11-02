import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import 'login_screen.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final hasToken = await _storageService.hasToken();
    if (!mounted) return;
    setState(() => _isLoggedIn = hasToken);
  }

  // Latihan 2: logout dengan dialog konfirmasi
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _storageService.deleteToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage & HTTP'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status login (Latihan 1)
            Card(
              color: _isLoggedIn ? Colors.green[50] : Colors.red[50],
              child: ListTile(
                leading: Icon(
                  _isLoggedIn ? Icons.verified_user : Icons.gpp_bad,
                  color: _isLoggedIn ? Colors.green : Colors.red,
                ),
                title: Text(
                  _isLoggedIn ? 'Status: Sudah login' : 'Status: Belum login',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Token sengaja TIDAK ditampilkan, hanya statusnya.
                subtitle: Text(_isLoggedIn
                    ? 'Token tersimpan terenkripsi di secure storage'
                    : 'Token tidak ditemukan'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('HTTP Request',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ambil data dari JSONPlaceholder menggunakan GET request.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserListScreen()),
                      ),
                      icon: const Icon(Icons.people),
                      label: const Text('Lihat Daftar Pengguna'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PostListScreen()),
                      ),
                      icon: const Icon(Icons.article),
                      label: const Text('Lihat Daftar Posts'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
