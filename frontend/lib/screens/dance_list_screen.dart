import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dance_provider.dart';
import 'dance_form_screen.dart';

class DanceListScreen extends StatefulWidget {
  const DanceListScreen({super.key});

  @override
  State<DanceListScreen> createState() => _DanceListScreenState();
}

class _DanceListScreenState extends State<DanceListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DanceProvider>().fetchDances());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DanceProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tari')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DanceFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(child: Text(p.error!))
          : RefreshIndicator(
              onRefresh: p.fetchDances,
              child: ListView.builder(
                itemCount: p.dances.length,
                itemBuilder: (_, i) {
                  final d = p.dances[i];
                  final kebutuhan = d.roles.isEmpty
                      ? 'Kebutuhan pemain belum diatur'
                      : d.roles
                            .map((r) => '${r.jumlah} ${r.role.namaPeran}')
                            .join(', ');
                  return ListTile(
                    leading: Icon(
                      d.statusAktif ? Icons.check_circle : Icons.cancel,
                      color: d.statusAktif ? Colors.green : Colors.grey,
                    ),
                    title: Text(d.namaTari),
                    subtitle: Text(kebutuhan),
                    isThreeLine: false,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final msg = await p.deleteDance(d.id!);
                        if (msg != null && context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(msg)));
                        }
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DanceFormScreen(dance: d),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
