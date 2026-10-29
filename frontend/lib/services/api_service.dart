import 'package:dio/dio.dart';

class ApiService {
  // GANTI sesuai tempat menjalankan aplikasi:
  // Emulator Android : http://10.0.2.2:8000/api
  // Chrome / Windows : http://127.0.0.1:8000/api
  // HP asli          : http://IP-LAPTOP:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}