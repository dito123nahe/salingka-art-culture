import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../providers/client_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama;
  late TextEditingController _noWa;
  String _sumber = 'WhatsApp';

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.client?.nama ?? '');
    _noWa = TextEditingController(text: widget.client?.noWa ?? '');
    _sumber = widget.client?.sumber ?? 'WhatsApp';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Client(
      id: widget.client?.id,
      nama: _nama.text.trim(),
      noWa: _noWa.text.trim().isEmpty ? null : _noWa.text.trim(),
      sumber: _sumber,
    );
    final p = context.read<ClientProvider>();
    try {
      if (widget.client == null) {
        await p.addClient(c);
      } else {
        await p.updateClient(c);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan klien')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Tambah Klien' : 'Ubah Klien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama pemesan'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _noWa,
                decoration: const InputDecoration(
                  labelText: 'No. WhatsApp',
                  helperText: 'Format: 6281234567890 (tanpa + dan 0)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sumber,
                decoration: const InputDecoration(labelText: 'Sumber pesanan'),
                items: const [
                  DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
                  DropdownMenuItem(
                    value: 'Instagram',
                    child: Text('Instagram'),
                  ),
                ],
                onChanged: (v) => setState(() => _sumber = v!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
