import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dance.dart';
import '../providers/dance_provider.dart';
import '../providers/role_provider.dart';

class DanceFormScreen extends StatefulWidget {
  final Dance? dance;
  const DanceFormScreen({super.key, this.dance});

  @override
  State<DanceFormScreen> createState() => _DanceFormScreenState();
}

class _DanceFormScreenState extends State<DanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama;
  late TextEditingController _deskripsi;
  late bool _aktif;
  final Map<int, int> _counts = {}; // role_id -> jumlah

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.dance?.namaTari ?? '');
    _deskripsi = TextEditingController(text: widget.dance?.deskripsi ?? '');
    _aktif = widget.dance?.statusAktif ?? true;
    for (final r in widget.dance?.roles ?? <DanceRole>[]) {
      _counts[r.role.id!] = r.jumlah;
    }
    Future.microtask(() => context.read<RoleProvider>().fetchRoles());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final roles = context.read<RoleProvider>().roles;
    final chosen = roles
        .where((r) => (_counts[r.id] ?? 0) > 0)
        .map((r) => DanceRole(role: r, jumlah: _counts[r.id]!))
        .toList();
    final d = Dance(
      id: widget.dance?.id,
      namaTari: _nama.text.trim(),
      deskripsi: _deskripsi.text.trim().isEmpty ? null : _deskripsi.text.trim(),
      statusAktif: _aktif,
      roles: chosen,
    );
    final p = context.read<DanceProvider>();
    try {
      if (widget.dance == null) {
        await p.addDance(d);
      } else {
        await p.updateDance(d);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan tari')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = context.watch<RoleProvider>().roles;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dance == null ? 'Tambah Tari' : 'Ubah Tari'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama tari'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              SwitchListTile(
                title: const Text('Tari aktif'),
                value: _aktif,
                onChanged: (v) => setState(() => _aktif = v),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Kebutuhan pemain',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...roles.map((r) {
                final n = _counts[r.id] ?? 0;
                return ListTile(
                  title: Text(r.namaPeran),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: n > 0
                            ? () => setState(() => _counts[r.id!] = n - 1)
                            : null,
                      ),
                      Text('$n', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _counts[r.id!] = n + 1),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
