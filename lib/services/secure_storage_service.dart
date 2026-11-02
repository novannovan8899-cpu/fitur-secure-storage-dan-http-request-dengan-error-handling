import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Key yang digunakan
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  /// Menyimpan token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Logging aman: tidak mencetak nilai token
    _log('Token berhasil disimpan');
  }

  /// Membaca token. Mengembalikan `null` jika belum ada.
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    // Logging aman: hanya menyebutkan status
    _log(token != null ? 'Token ditemukan' : 'Token tidak ditemukan');
    return token;
  }

  /// Menghapus token.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _log('Token berhasil dihapus');
  }

  /// Mengecek keberadaan token.
  Future<bool> hasToken() {
    return _storage.containsKey(key: _tokenKey);
  }

  // ---------------------------------------------------------------------------
  // PIN
  // ---------------------------------------------------------------------------

  /// Menyimpan PIN.
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    _log('PIN berhasil disimpan');
  }

  /// Membaca PIN. Mengembalikan `null` jika belum ada.
  Future<String?> getPin() {
    return _storage.read(key: _pinKey);
  }

  // ---------------------------------------------------------------------------
  // Umum
  // ---------------------------------------------------------------------------

  /// Menghapus semua data yang tersimpan.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    _log('Semua data berhasil dihapus');
  }

  // Logging hanya aktif pada mode debug
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[SecureStorage] $message');
    }
  }
}