import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/client_provider.dart';
import 'client_form_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ClientProvider>().fetchClients());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ClientProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Klien')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(child: Text(p.error!))
          : RefreshIndicator(
              onRefresh: p.fetchClients,
              child: ListView.builder(
                itemCount: p.clients.length,
                itemBuilder: (_, i) {
                  final c = p.clients[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.nama[0].toUpperCase())),
                    title: Text(c.nama),
                    subtitle: Text('${c.noWa ?? '-'} • ${c.sumber ?? '-'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final msg = await p.deleteClient(c.id!);
                        if (msg != null && context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(msg)));
                        }
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientFormScreen(client: c),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
