import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> bookings = [];
  bool loading = false;
  String? error;

  Future<void> fetchBookings() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dio.get('/bookings');
      bookings = (res.data as List).map((e) => Booking.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat booking. Pastikan server berjalan.';
    }
    loading = false;
    notifyListeners();
  }

  Future<int> addBooking(Booking b) async {
    final res = await ApiService.dio.post('/bookings', data: b.toJson());
    await fetchBookings();
    return (res.data['bentrok'] as List? ?? []).length;
  }

  Future<int> updateBooking(Booking b) async {
    final res = await ApiService.dio.put('/bookings/${b.id}', data: b.toJson());
    await fetchBookings();
    return (res.data['bentrok'] as List? ?? []).length;
  }

  Future<String?> deleteBooking(int id) async {
    try {
      await ApiService.dio.delete('/bookings/$id');
      await fetchBookings();
      return null;
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Gagal menghapus booking';
    }
  }
}
