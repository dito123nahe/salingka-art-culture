import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../services/api_service.dart';

class HonorScreen extends StatefulWidget {
  final Booking booking;
  const HonorScreen({super.key, required this.booking});

  @override
  State<HonorScreen> createState() => _HonorScreenState();
}

class _HonorScreenState extends State<HonorScreen> {
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Map<String, dynamic> _d = {};
  bool _loading = true;
  String? _error;

  String get _base => '/bookings/${widget.booking.id}/honor';

  List get _rows => (_d['data'] as List?) ?? [];
  double _n(String k) => double.tryParse('${_d[k] ?? 0}') ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _pesan(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.dio.get(_base);
      _d = Map<String, dynamic>.from(res.data);
    } catch (e) {
      _error = 'Gagal memuat honor. Pastikan server berjalan.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _hitung() async {
    try {
      final res = await ApiService.dio.post('$_base/hitung');
      setState(() => _d = Map<String, dynamic>.from(res.data));
    } catch (e) {
      _pesan('Belum ada pemain yang ditugaskan di booking ini');
    }
  }

  Future<void> _ubah(int id, Map<String, dynamic> data) async {
    try {
      final res = await ApiService.dio.put('$_base/$id', data: data);
      setState(() => _d = Map<String, dynamic>.from(res.data));
    } catch (e) {
      _pesan('Gagal menyimpan perubahan');
    }
  }

  Future<void> _editNominal(Map h) async {
    final c = TextEditingController(
      text: (double.tryParse('${h['jumlah_honor']}') ?? 0).toStringAsFixed(0),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Honor ${h['nama']}'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final v = double.tryParse(c.text.trim());
    if (v == null || v < 0) {
      _pesan('Nominal harus berupa angka');
      return;
    }
    await _ubah(h['id'], {'jumlah_honor': v});
  }

  @override
  Widget build(BuildContext context) {
    final selisih = _n('selisih');
    return Scaffold(
      appBar: AppBar(title: Text('Honor - ${widget.booking.jenisAcara}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dana honor: ${_rupiah.format(_n('dana_honor'))}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total dibagikan: ${_rupiah.format(_n('total_dibagikan'))}',
                        ),
                        Text(
                          selisih >= 0
                              ? 'Sisa dana: ${_rupiah.format(selisih)}'
                              : 'Melebihi dana: ${_rupiah.format(-selisih)}',
                          style: TextStyle(
                            color: selisih < 0 ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _hitung,
                          icon: const Icon(Icons.calculate),
                          label: Text(
                            _rows.isEmpty ? 'Hitung honor' : 'Hitung ulang',
                          ),
                        ),
                        const Text(
                          'Yang sudah dibayar tidak ditimpa saat hitung ulang.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada honor. Atur pemain dan pembukuan dulu, lalu tekan Hitung honor.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final h in _rows)
                  Card(
                    child: ListTile(
                      title: Text(h['nama']),
                      subtitle: Text(
                        '${h['jumlah_penampilan']} penampilan • ${_rupiah.format(double.tryParse('${h['jumlah_honor']}') ?? 0)}',
                      ),
                      onTap: h['status_bayar'] == 'sudah'
                          ? null
                          : () => _editNominal(h),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            h['status_bayar'] == 'sudah' ? 'Dibayar' : 'Belum',
                          ),
                          Checkbox(
                            value: h['status_bayar'] == 'sudah',
                            onChanged: (v) => _ubah(h['id'], {
                              'status_bayar': v == true ? 'sudah' : 'belum',
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
