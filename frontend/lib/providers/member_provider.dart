import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/api_service.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> members = [];
  bool loading = false;
  String? error;

  Future<void> fetchMembers() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dio.get('/members');
      members = (res.data as List).map((e) => Member.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat data. Pastikan server berjalan.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addMember(Member m) async {
    await ApiService.dio.post('/members', data: m.toJson());
    await fetchMembers();
  }

  Future<void> updateMember(Member m) async {
    await ApiService.dio.put('/members/${m.id}', data: m.toJson());
    await fetchMembers();
  }

  Future<void> deleteMember(int id) async {
    await ApiService.dio.delete('/members/$id');
    await fetchMembers();
  }
}