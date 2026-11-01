import 'package:flutter/material.dart';

import '../models/role.dart';
import '../services/api_service.dart';

class RoleProvider extends ChangeNotifier {
  List<Role> roles = [];
  bool loading = false;
  String? error;

  Future<void> fetchRoles() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dio.get('/roles');
      roles = (res.data as List).map((e) => Role.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat peran. Pastikan server berjalan.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addRole(String nama) async {
    await ApiService.dio.post('/roles', data: {'nama_peran': nama});
    await fetchRoles();
  }

  Future<void> deleteRole(int id) async {
    await ApiService.dio.delete('/roles/$id');
    await fetchRoles();
  }
}
