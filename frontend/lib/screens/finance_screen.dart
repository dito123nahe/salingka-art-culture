import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  final Booking booking;
  const FinanceScreen({super.key, required this.booking});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<dynamic> _transaksi = [];
  Map<String, dynamic> _r = {};
  bool _loading = true;
  String? _error;

  String get _base => '/bookings/${widget.booking.id}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _n(String k) => double.tryParse('${_r[k] ?? 0}') ?? 0;

  void _terapkan(Map data) {
    _transaksi = data['transaksi'] as List;
    _r = Map<String, dynamic>.from(data['ringkasan']);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.dio.get('$_base/transactions');
      _terapkan(res.data);
    } catch (e) {
      _error = 'Gagal memuat pembukuan. Pastikan server berjalan.';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _pesan(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  Future<void> _tambah() async {
    String jenis = 'pemasukan';
    final ket = TextEditingController();
    final jml = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Tambah transaksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'pemasukan', label: Text('Pemasukan')),
                    ButtonSegment(
                      value: 'pengeluaran',
                      label: Text('Pengeluaran'),
                    ),
                  ],
                  selected: {jenis},
                  onSelectionChanged: (s) => setD(() => jenis = s.first),
                ),
                TextField(
                  controller: ket,
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    helperText: jenis == 'pemasukan'
                        ? 'Contoh: DP, Pelunasan'
                        : 'Contoh: Transport, Kostum',
                  ),
                ),
                TextField(
                  controller: jml,
                  decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
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
      ),
    );
    if (ok != true) return;
    final nilai = double.tryParse(jml.text.trim());
    if (nilai == null || nilai <= 0) {
      _pesan('Jumlah harus berupa angka');
      return;
    }
    final now = DateTime.now();
    final tgl =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final res = await ApiService.dio.post(
        '$_base/transactions',
        data: {
          'jenis': jenis,
          'keterangan': ket.text.trim().isEmpty ? null : ket.text.trim(),
          'jumlah': nilai,
          'tanggal': tgl,
        },
      );
      setState(() => _terapkan(res.data));
    } catch (e) {
      _pesan('Gagal menyimpan transaksi');
    }
  }

  Future<void> _hapus(int id) async {
    try {
      final res = await ApiService.dio.delete('$_base/transactions/$id');
      setState(() => _terapkan(res.data));
    } catch (e) {
      _pesan('Gagal menghapus transaksi');
    }
  }

  Future<void> _aturKas() async {
    String tipe = '${_r['kas_tipe'] ?? 'nominal'}';
    final nilai = TextEditingController(
      text: _n('kas_nilai') == 0 ? '' : _n('kas_nilai').toStringAsFixed(0),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Kas sanggar untuk job ini'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'nominal', label: Text('Nominal')),
                  ButtonSegment(value: 'persen', label: Text('Persen')),
                ],
                selected: {tipe},
                onSelectionChanged: (s) => setD(() => tipe = s.first),
              ),
              TextField(
                controller: nilai,
                decoration: InputDecoration(
                  labelText: tipe == 'persen'
                      ? 'Persen dari laba (%)'
                      : 'Nominal (Rp)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
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
      ),
    );
    if (ok != true) return;
    final v = double.tryParse(nilai.text.trim()) ?? 0;
    try {
      final res = await ApiService.dio.put(
        '$_base/kas',
        data: {'kas_tipe': tipe, 'kas_nilai': v},
      );
      setState(() => _terapkan(res.data));
    } catch (e) {
      _pesan('Gagal menyimpan kas (persen maksimal 100)');
    }
  }

  Widget _baris(
    String label,
    String nilai, {
    bool tebal = false,
    Color? warna,
  }) {
    final style = TextStyle(
      fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
      color: warna,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(nilai, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pembukuan - ${widget.booking.jenisAcara}')),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _tambah,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _baris(
                            'Total biaya',
                            _rupiah.format(_n('total_biaya')),
                          ),
                          _baris(
                            'Sudah dibayar',
                            _rupiah.format(_n('pemasukan')),
                            warna: Colors.green,
                          ),
                          _baris(
                            'Sisa tagihan',
                            _rupiah.format(_n('sisa_tagihan')),
                            warna: _n('sisa_tagihan') > 0
                                ? Colors.orange
                                : null,
                          ),
                          const Divider(),
                          _baris(
                            'Pengeluaran',
                            _rupiah.format(_n('pengeluaran')),
                            warna: Colors.red,
                          ),
                          _baris(
                            'Laba kotor',
                            _rupiah.format(_n('laba_kotor')),
                            tebal: true,
                          ),
                          _baris(
                            _r['kas_tipe'] == 'persen'
                                ? 'Kas sanggar (${_n('kas_nilai').toStringAsFixed(0)}%)'
                                : 'Kas sanggar',
                            _rupiah.format(_n('kas')),
                          ),
                          const Divider(),
                          _baris(
                            'Dana honor',
                            _rupiah.format(_n('dana_honor')),
                            tebal: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _aturKas,
                              icon: const Icon(Icons.savings),
                              label: const Text('Atur kas'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_transaksi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada transaksi'),
                    ),
                  for (final t in _transaksi)
                    ListTile(
                      leading: Icon(
                        t['jenis'] == 'pemasukan'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: t['jenis'] == 'pemasukan'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(t['keterangan'] ?? t['jenis']),
                      subtitle: Text('${t['tanggal']}'.substring(0, 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _rupiah.format(
                              double.tryParse('${t['jumlah']}') ?? 0,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _hapus(t['id']),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
