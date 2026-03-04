import 'package:flutter/foundation.dart';

// logger untuk print sebuah pesan dengan tag tertentu, hanya aktif di debug mode, tidak akan muncul di release mode
// jangan asal untuk print sesuatu, gunakan AppLogger.d('TAG', 'Pesan') agar lebih mudah untuk mencari log yang diinginkan
// jangan gunakan print langsung, karena akan sulit untuk mencari log yang diinginkan, apalagi jika banyak log yang muncul

class AppLogger {
  static void d(String tag, String message) {
    if (kDebugMode) print('[$tag] $message');
  }

  static void i(String tag, String message) {
    if (kDebugMode) print('[INFO][$tag] $message');
  }

  static void w(String tag, String message) {
    if (kDebugMode) print('[WARN][$tag] $message');
  }

  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print('[ERROR][$tag] $message');
      if (error != null) print('   Caused by: $error');
      if (stackTrace != null) print('   StackTrace: $stackTrace');
    }
  }

  static void api(String tag, String message) {
    if (kDebugMode) print('[API][$tag] $message');
  }
}

//? contoh penggunaan:
// AppLogger.d('ProductRepository', 'Fetching products from local database');

// +------------------+---------------------------+------------------------------------------------+
// | Method           | Singkatan                 | Kapan Dipakai                                  |
// +------------------+---------------------------+------------------------------------------------+
// | AppLogger.d      | Debug                     | Info umum saat development, cek nilai variabel |
// | AppLogger.i      | Info                      | Catat alur / flow penting                      |
// | AppLogger.w      | Warning                   | Ada yang janggal tapi app masih jalan          |
// | AppLogger.e      | Error                     | Ada exception / sesuatu gagal                  |
// | AppLogger.api    | API                       | Khusus request & response API                  |
// +------------------+---------------------------+------------------------------------------------+
