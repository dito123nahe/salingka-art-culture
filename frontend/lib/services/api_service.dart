import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Diisi saat menjalankan di HP asli (lihat Langkah 3)
  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://127.0.0.1:8000/api'; // Chrome
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api'; // Emulator
    return 'http://127.0.0.1:8000/api'; // Windows desktop
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
