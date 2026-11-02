import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/client.dart';
import '../services/api_service.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> clients = [];
  bool loading = false;
  String? error;

  Future<void> fetchClients() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dio.get('/clients');
      clients = (res.data as List).map((e) => Client.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat klien. Pastikan server berjalan.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addClient(Client c) async {
    await ApiService.dio.post('/clients', data: c.toJson());
    await fetchClients();
  }

  Future<void> updateClient(Client c) async {
    await ApiService.dio.put('/clients/${c.id}', data: c.toJson());
    await fetchClients();
  }

  Future<String?> deleteClient(int id) async {
    try {
      await ApiService.dio.delete('/clients/$id');
      await fetchClients();
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Gagal menghapus klien';
    }
  }
}
