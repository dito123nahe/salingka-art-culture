import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/client_provider.dart';
import '../providers/dance_provider.dart';

class BookingFormScreen extends StatefulWidget {
  final Booking? booking;
  const BookingFormScreen({super.key, this.booking});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _acara;
  late TextEditingController _lokasi;
  late TextEditingController _maps;
  late TextEditingController _biaya;
  late TextEditingController _catatan;
  int? _clientId;
  String? _tanggal;
  String? _jamMulai;
  String? _jamSelesai;
  String _status = 'menunggu';
  final Set<int> _danceIds = {};

  static const _statuses = ['menunggu', 'dp', 'lunas', 'selesai', 'batal'];

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _acara = TextEditingController(text: b?.jenisAcara ?? '');
    _lokasi = TextEditingController(text: b?.lokasi ?? '');
    _maps = TextEditingController(text: b?.linkMaps ?? '');
    _biaya = TextEditingController(
      text: b != null ? b.totalBiaya.toStringAsFixed(0) : '',
    );
    _catatan = TextEditingController(text: b?.catatan ?? '');
    _clientId = b?.clientId;
    _tanggal = b?.tanggal;
    _jamMulai = b?.jamMulai;
    _jamSelesai = b?.jamSelesai;
    _status = b?.status ?? 'menunggu';
    _danceIds.addAll((b?.dances ?? []).map((d) => d.id!));
    Future.microtask(() {
      context.read<ClientProvider>().fetchClients();
      context.read<DanceProvider>().fetchDances();
    });
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal != null ? DateTime.parse(_tanggal!) : now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) {
      setState(
        () => _tanggal =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pilihJam(bool mulai) async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (t != null) {
      final s =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      setState(() => mulai ? _jamMulai = s : _jamSelesai = s);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal acara wajib dipilih')),
      );
      return;
    }
    final allDances = context.read<DanceProvider>().dances;
    final b = Booking(
      id: widget.booking?.id,
      clientId: _clientId!,
      jenisAcara: _acara.text.trim(),
      tanggal: _tanggal!,
      jamMulai: _jamMulai,
      jamSelesai: _jamSelesai,
      lokasi: _lokasi.text.trim().isEmpty ? null : _lokasi.text.trim(),
      linkMaps: _maps.text.trim().isEmpty ? null : _maps.text.trim(),
      totalBiaya: double.tryParse(_biaya.text.trim()) ?? 0,
      status: _status,
      catatan: _catatan.text.trim().isEmpty ? null : _catatan.text.trim(),
      dances: allDances.where((d) => _danceIds.contains(d.id)).toList(),
    );
    final p = context.read<BookingProvider>();
    try {
      final bentrok = widget.booking == null
          ? await p.addBooking(b)
          : await p.updateBooking(b);
      if (!mounted) return;
      Navigator.pop(context);
      if (bentrok > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tersimpan. Peringatan: ada $bentrok booking lain di tanggal ini.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan booking')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().clients;
    final dances = context
        .watch<DanceProvider>()
        .dances
        .where((d) => d.statusAktif || _danceIds.contains(d.id))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Tambah Booking' : 'Ubah Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                initialValue: clients.any((c) => c.id == _clientId)
                    ? _clientId
                    : null,
                decoration: const InputDecoration(labelText: 'Klien'),
                items: clients
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.nama)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _clientId = v),
                validator: (v) => v == null ? 'Pilih klien' : null,
              ),
              TextFormField(
                controller: _acara,
                decoration: const InputDecoration(
                  labelText: 'Jenis acara (pernikahan, hajatan, dll.)',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_tanggal ?? 'Pilih tanggal acara'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pilihTanggal,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pilihJam(true),
                      child: Text(_jamMulai ?? 'Jam mulai'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pilihJam(false),
                      child: Text(_jamSelesai ?? 'Jam selesai'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _lokasi,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextFormField(
                controller: _maps,
                decoration: const InputDecoration(
                  labelText: 'Link Google Maps',
                  helperText: 'Tempel tautan dari Google Maps (https://...)',
                ),
                keyboardType: TextInputType.url,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return null;
                  return s.startsWith('http') ? null : 'Harus diawali https://';
                },
              ),
              TextFormField(
                controller: _biaya,
                decoration: const InputDecoration(
                  labelText: 'Total biaya (Rp)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') == null ? 'Isi angka' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              TextFormField(
                controller: _catatan,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 2,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Text(
                  'Tari yang dipesan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...dances.map(
                (d) => CheckboxListTile(
                  title: Text(d.namaTari),
                  value: _danceIds.contains(d.id),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _danceIds.add(d.id!);
                    } else {
                      _danceIds.remove(d.id);
                    }
                  }),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
