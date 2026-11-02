import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  // Latihan 5: timeout yang dapat dipilih (default 10 detik)
  Duration _timeout = ApiService.defaultTimeout;
  static const List<Duration> _timeoutOptions = [
    Duration(milliseconds: 1),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final users = await _apiService.getUsers(timeout: _timeout);
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Latihan 4: filter berdasarkan nama atau email
  List<User> get _filteredUsers {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _users;
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  String _label(Duration d) => d.inSeconds >= 1
      ? '${d.inSeconds} detik'
      : '${d.inMilliseconds} ms (uji timeout)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<Duration>(
            icon: const Icon(Icons.timer),
            tooltip: 'Atur timeout',
            initialValue: _timeout,
            onSelected: (d) {
              setState(() => _timeout = d);
              _loadUsers();
            },
            itemBuilder: (context) => _timeoutOptions
                .map((d) => CheckedPopupMenuItem<Duration>(
                      value: d,
                      checked: d == _timeout,
                      child: Text('Timeout: ${_label(d)}'),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Terjadi Kesalahan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('Tidak ada data pengguna'));
    }

    final users = _filteredUsers;

    return Column(
      children: [
        // Kolom pencarian (real-time)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: users.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text('Tidak ada hasil untuk "$_query"'),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(
                        user: user,
                        onTap: () => _showUserDetail(user),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _showUserDetail(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Username: ${user.username}'),
            Text('Email: ${user.email}'),
            Text('Telepon: ${user.phone}'),
            Text('Website: ${user.website}'),
            Text('Perusahaan: ${user.companyName}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
