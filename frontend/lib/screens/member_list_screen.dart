import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'role_list_screen.dart';
import 'dance_list_screen.dart';
import 'client_list_screen.dart';
import 'booking_list_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MemberProvider>().fetchMembers());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MemberProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Sanggar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge),
            tooltip: 'Kelola peran',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoleListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.festival),
            tooltip: 'Kelola tari',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DanceListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            tooltip: 'Kelola klien',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClientListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.event),
            tooltip: 'Booking',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingListScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MemberFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(child: Text(p.error!))
          : RefreshIndicator(
              onRefresh: p.fetchMembers,
              child: ListView.builder(
                itemCount: p.members.length,
                itemBuilder: (_, i) {
                  final m = p.members[i];
                  final peran = m.roles.isEmpty
                      ? 'Belum ada peran'
                      : m.roles.map((r) => r.namaPeran).join(', ');
                  return ListTile(
                    leading: CircleAvatar(child: Text(m.nama[0].toUpperCase())),
                    title: Text(m.nama),
                    subtitle: Text('${m.noHp ?? '-'}\n$peran'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.statusAktif ? Icons.check_circle : Icons.cancel,
                          color: m.statusAktif ? Colors.green : Colors.grey,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => p.deleteMember(m.id!),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberFormScreen(member: m),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
