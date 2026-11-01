import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/dance.dart';
import '../services/api_service.dart';

class DanceProvider extends ChangeNotifier {
  List<Dance> dances = [];
  bool loading = false;
  String? error;

  Future<void> fetchDances() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dio.get('/dances');
      dances = (res.data as List).map((e) => Dance.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat tari. Pastikan server berjalan.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addDance(Dance d) async {
    await ApiService.dio.post('/dances', data: d.toJson());
    await fetchDances();
  }

  Future<void> updateDance(Dance d) async {
    await ApiService.dio.put('/dances/${d.id}', data: d.toJson());
    await fetchDances();
  }

  /// Mengembalikan pesan error, atau null kalau berhasil.
  Future<String?> deleteDance(int id) async {
    try {
      await ApiService.dio.delete('/dances/$id');
      await fetchDances();
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Gagal menghapus tari';
    }
  }
}
