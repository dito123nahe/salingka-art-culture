import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'honor_screen.dart';
import 'finance_screen.dart';
import 'assignment_screen.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import 'booking_form_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookingProvider>().fetchBookings());
  }

  Color _warna(String s) {
    switch (s) {
      case 'dp':
        return Colors.orange;
      case 'lunas':
        return Colors.green;
      case 'selesai':
        return Colors.blueGrey;
      case 'batal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _bukaPeta(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka peta')));
    }
  }

  Future<void> _kirimWa(Booking b) async {
    final raw = b.client?.noWa ?? '';
    var no = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (no.startsWith('0')) no = '62${no.substring(1)}';
    if (no.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Klien belum punya nomor WhatsApp')),
      );
      return;
    }
    final tari = b.dances.isEmpty
        ? '-'
        : b.dances.map((d) => d.namaTari).join(', ');
    final tgl = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(DateTime.parse(b.tanggal));
    final jam = b.jamMulai != null ? ' pukul ${b.jamMulai}' : '';
    final peta = b.linkMaps != null ? 'Peta: ${b.linkMaps}\n' : '';
    final pesan =
        'Halo ${b.client?.nama ?? ''}, konfirmasi pesanan '
        'Salingka Art & Culture:\n'
        'Acara: ${b.jenisAcara}\n'
        'Tanggal: $tgl$jam\n'
        'Lokasi: ${b.lokasi ?? '-'}\n'
        '$peta'
        'Tari: $tari\n'
        'Total biaya: ${_rupiah.format(b.totalBiaya)}\n'
        'Status: ${b.status.toUpperCase()}\n'
        'Terima kasih.';
    final uri = Uri.parse(
      'https://wa.me/$no?text=${Uri.encodeComponent(pesan)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(child: Text(p.error!))
          : RefreshIndicator(
              onRefresh: p.fetchBookings,
              child: ListView.builder(
                itemCount: p.bookings.length,
                itemBuilder: (_, i) {
                  final b = p.bookings[i];
                  final tari = b.dances.isEmpty
                      ? 'Belum ada tari'
                      : b.dances.map((d) => d.namaTari).join(', ');
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text('${b.jenisAcara} - ${b.client?.nama ?? '-'}'),
                      subtitle: Text(
                        '${b.tanggal}'
                        '${b.jamMulai != null ? ' • ${b.jamMulai}' : ''}\n'
                        '${b.lokasi ?? '-'}\n'
                        '$tari\n${_rupiah.format(b.totalBiaya)}',
                      ),
                      isThreeLine: true,
                      leading: Chip(
                        label: Text(
                          b.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: _warna(b.status),
                        padding: EdgeInsets.zero,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (b.linkMaps != null)
                            IconButton(
                              icon: const Icon(Icons.payments),
                              tooltip: 'Honor pemain',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HonorScreen(booking: b),
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.account_balance_wallet),
                            tooltip: 'Pembukuan',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FinanceScreen(booking: b),
                                ),
                              );
                              if (context.mounted) {
                                context.read<BookingProvider>().fetchBookings();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.groups),
                            tooltip: 'Atur pemain',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssignmentScreen(booking: b),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.map),
                            tooltip: 'Buka peta',
                            onPressed: () => _bukaPeta(b.linkMaps!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat),
                            tooltip: 'Kirim ke WhatsApp',
                            onPressed: () => _kirimWa(b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final msg = await p.deleteBooking(b.id!);
                              if (msg != null && context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(booking: b),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
