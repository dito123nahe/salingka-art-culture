import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member;
  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama;
  late TextEditingController _noHp;
  late bool _aktif;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.member?.nama ?? '');
    _noHp = TextEditingController(text: widget.member?.noHp ?? '');
    _aktif = widget.member?.statusAktif ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<MemberProvider>();
    final m = Member(
      id: widget.member?.id,
      nama: _nama.text.trim(),
      noHp: _noHp.text.trim().isEmpty ? null : _noHp.text.trim(),
      statusAktif: _aktif,
    );
    try {
      if (widget.member == null) {
        await p.addMember(m);
      } else {
        await p.updateMember(m);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'Tambah Anggota' : 'Ubah Anggota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _noHp,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text('Anggota aktif'),
                value: _aktif,
                onChanged: (v) => setState(() => _aktif = v),
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