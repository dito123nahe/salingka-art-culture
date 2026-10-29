import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import 'member_form_screen.dart';

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
      appBar: AppBar(title: const Text('Anggota Sanggar')),
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
                      return ListTile(
                        leading: CircleAvatar(child: Text(m.nama[0].toUpperCase())),
                        title: Text(m.nama),
                        subtitle: Text(m.noHp ?? '-'),
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