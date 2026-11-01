import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/role_provider.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoleProvider>().fetchRoles());
  }

  Future<void> _tambah() async {
    final c = TextEditingController();
    final nama = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Peran'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Nama peran'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (nama != null && nama.isNotEmpty && mounted) {
      await context.read<RoleProvider>().addRole(nama);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RoleProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Peran')),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambah,
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(child: Text(p.error!))
          : ListView.builder(
              itemCount: p.roles.length,
              itemBuilder: (_, i) {
                final r = p.roles[i];
                return ListTile(
                  title: Text(r.namaPeran),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => p.deleteRole(r.id!),
                  ),
                );
              },
            ),
    );
  }
}
