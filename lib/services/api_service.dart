import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';

/// Exception khusus dengan pesan yang ramah pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration defaultTimeout = Duration(seconds: 10);

  // Latihan 5: timeout dapat dikonfigurasi lewat parameter (default 10 detik)
  Future<List<User>> getUsers({Duration timeout = defaultTimeout}) {
    return _getList<User>('/users', timeout, User.fromJson);
  }

  // Latihan 3: GET /posts
  Future<List<Post>> getPosts({Duration timeout = defaultTimeout}) {
    return _getList<Post>('/posts', timeout, Post.fromJson);
  }

  // GET /users/{id}
  Future<User> getUserById(int id, {Duration timeout = defaultTimeout}) async {
    try {
      print('Request GET: $_baseUrl/users/$id');
      final response =
          await http.get(Uri.parse('$_baseUrl/users/$id')).timeout(timeout);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException('Gagal memuat data. Status: ${response.statusCode}');
    } catch (e) {
      throw _mapError(e, timeout);
    }
  }

  // Simulasi login untuk mendapatkan token
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      throw ApiException('Email dan password tidak boleh kosong');
    }

    // Token dummy (di aplikasi nyata token berasal dari server)
    final token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';

    // Logging aman: tidak mencetak token, email, maupun password
    print('Login berhasil');
    return token;
  }

  Future<List<T>> _getList<T>(
    String endpoint,
    Duration timeout,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      print('Request GET: $_baseUrl$endpoint');
      final response =
          await http.get(Uri.parse('$_baseUrl$endpoint')).timeout(timeout);

      // Logging aman: hanya status code
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException('Gagal memuat data. Status: ${response.statusCode}');
    } catch (e) {
      throw _mapError(e, timeout);
    }
  }

  ApiException _mapError(Object e, Duration timeout) {
    if (e is ApiException) return e;
    if (e is TimeoutException) {
      return ApiException(
        'Request timeout setelah ${_formatDuration(timeout)}. '
        'Periksa koneksi internet Anda.',
      );
    }
    if (e is SocketException || e is http.ClientException) {
      return ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }
    if (e is FormatException) {
      return ApiException('Format data tidak valid.');
    }
    return ApiException('Terjadi kesalahan: $e');
  }

  String _formatDuration(Duration d) =>
      d.inSeconds >= 1 ? '${d.inSeconds} detik' : '${d.inMilliseconds} ms';
}