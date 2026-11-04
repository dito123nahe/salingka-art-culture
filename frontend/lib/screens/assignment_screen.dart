import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assignment.dart';
import '../models/booking.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../services/api_service.dart';

class AssignmentScreen extends StatefulWidget {
  final Booking booking;
  const AssignmentScreen({super.key, required this.booking});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  List<DanceLineup> _lineups = [];
  // key: "bookingDanceId|roleId|index" -> member_id
  final Map<String, int?> _pilihan = {};
  bool _loading = true;
  String? _error;

  String _key(int bd, int role, int i) => '$bd|$role|$i';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await context.read<MemberProvider>().fetchMembers();
      final res = await ApiService.dio.get(
        '/bookings/${widget.booking.id}/assignments',
      );
      final lineups = (res.data as List)
          .map((e) => DanceLineup.fromJson(e))
          .toList();
      for (final l in lineups) {
        for (final n in l.kebutuhan) {
          final terisi = l.assignments
              .where((a) => a.roleId == n.roleId)
              .toList();
          for (var i = 0; i < n.jumlah; i++) {
            _pilihan[_key(l.bookingDanceId, n.roleId, i)] = i < terisi.length
                ? terisi[i].memberId
                : null;
          }
        }
      }
      setState(() {
        _lineups = lineups;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat susunan pemain.';
        _loading = false;
      });
    }
  }

  // Anggota terpilih di tari ini (semua peran), kecuali slot tertentu
  Set<int> _terpakai(DanceLineup l, String exceptKey) {
    final s = <int>{};
    for (final n in l.kebutuhan) {
      for (var i = 0; i < n.jumlah; i++) {
        final k = _key(l.bookingDanceId, n.roleId, i);
        final v = _pilihan[k];
        if (k != exceptKey && v != null) s.add(v);
      }
    }
    return s;
  }

  Future<void> _simpan() async {
    final items = _lineups.map((l) {
      final list = <Map<String, int>>[];
      for (final n in l.kebutuhan) {
        for (var i = 0; i < n.jumlah; i++) {
          final v = _pilihan[_key(l.bookingDanceId, n.roleId, i)];
          if (v != null) list.add({'member_id': v, 'role_id': n.roleId});
        }
      }
      return {'booking_dance_id': l.bookingDanceId, 'assignments': list};
    }).toList();

    try {
      final res = await ApiService.dio.put(
        '/bookings/${widget.booking.id}/assignments',
        data: {'items': items},
      );
      final bentrok = (res.data['bentrok'] as List? ?? []).cast<String>();
      if (!mounted) return;
      Navigator.pop(context);
      if (bentrok.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tersimpan. Peringatan: ${bentrok.join(', ')} juga bertugas di acara lain pada tanggal ini.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan susunan pemain')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    return Scaffold(
      appBar: AppBar(title: Text('Pemain - ${widget.booking.jenisAcara}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _lineups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Booking ini belum punya tari. Ubah booking dan pilih tari dulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final l in _lineups) ...[
                  Text(
                    l.namaTari,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (l.kebutuhan.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Kebutuhan pemain tari ini belum diatur.'),
                    ),
                  for (final n in l.kebutuhan)
                    for (var i = 0; i < n.jumlah; i++) _slot(l, n, i, members),
                  const Divider(height: 32),
                ],
                ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
              ],
            ),
    );
  }

  Widget _slot(DanceLineup l, NeedRole n, int i, List<Member> members) {
    final k = _key(l.bookingDanceId, n.roleId, i);
    final dipakai = _terpakai(l, k);
    final kandidat = members.where(
      (m) =>
          (m.statusAktif || m.id == _pilihan[k]) &&
          m.roles.any((r) => r.id == n.roleId) &&
          !dipakai.contains(m.id),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<int>(
        key: ValueKey('$k-${_pilihan[k]}'),
        initialValue: _pilihan[k],
        decoration: InputDecoration(labelText: '${n.namaPeran} ${i + 1}'),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('- kosong -')),
          ...kandidat.map(
            (m) => DropdownMenuItem(value: m.id, child: Text(m.nama)),
          ),
        ],
        onChanged: (v) => setState(() => _pilihan[k] = v),
      ),
    );
  }
}
