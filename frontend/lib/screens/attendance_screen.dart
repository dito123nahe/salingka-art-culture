import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _tanggal = DateTime.now();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  String get _tglStr =>
      '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}';

  int get _jumlahHadir => _rows.where((r) => r['status'] == 'hadir').length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.dio.get(
        '/attendances',
        queryParameters: {'tanggal': _tglStr},
      );
      _rows = (res.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      _error = 'Gagal memuat absensi. Pastikan server berjalan.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (d != null) {
      _tanggal = d;
      await _load();
    }
  }

  void _setSemua(bool hadir) {
    setState(() {
      for (final r in _rows) {
        r['status'] = hadir ? 'hadir' : 'tidak';
      }
    });
  }

  Future<void> _simpan() async {
    try {
      await ApiService.dio.post(
        '/attendances',
        data: {
          'tanggal': _tglStr,
          'items': _rows
              .map(
                (r) => {
                  'member_id': r['member_id'],
                  'status': r['status'] == 'hadir' ? 'hadir' : 'tidak',
                },
              )
              .toList(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Absensi tersimpan')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan absensi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Latihan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Rekap kehadiran',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceRekapScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Tanggal latihan: $_tglStr'),
            subtitle: Text('Hadir: $_jumlahHadir dari ${_rows.length} anggota'),
            onTap: _pilihTanggal,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => _setSemua(true),
                  child: const Text('Semua hadir'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _setSemua(false),
                  child: const Text('Kosongkan'),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _rows.isEmpty
                ? const Center(child: Text('Belum ada anggota aktif'))
                : ListView.builder(
                    itemCount: _rows.length,
                    itemBuilder: (_, i) {
                      final r = _rows[i];
                      return CheckboxListTile(
                        title: Text(r['nama']),
                        value: r['status'] == 'hadir',
                        onChanged: (v) => setState(
                          () => r['status'] = v == true ? 'hadir' : 'tidak',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _loading ? null : _simpan,
          child: const Text('Simpan'),
        ),
      ),
    );
  }
}

class AttendanceRekapScreen extends StatefulWidget {
  const AttendanceRekapScreen({super.key});

  @override
  State<AttendanceRekapScreen> createState() => _AttendanceRekapScreenState();
}

class _AttendanceRekapScreenState extends State<AttendanceRekapScreen> {
  List<dynamic> _data = [];
  int _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.dio.get('/attendances/rekap');
      _data = res.data['data'];
      _total = res.data['total_sesi'];
    } catch (e) {
      _error = 'Gagal memuat rekap.';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Kehadiran')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Total sesi latihan tercatat: $_total'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (_, i) {
                      final d = _data[i];
                      return ListTile(
                        title: Text(d['nama']),
                        subtitle: LinearProgressIndicator(
                          value: (d['persen'] as num) / 100,
                        ),
                        trailing: Text(
                          '${d['hadir']}/${d['total_sesi']}  (${d['persen']}%)',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
