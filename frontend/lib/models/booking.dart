import 'client.dart';
import 'dance.dart';

class Booking {
  final int? id;
  final int clientId;
  final Client? client;
  final String jenisAcara;
  final String tanggal; // yyyy-MM-dd
  final String? jamMulai; // HH:mm
  final String? jamSelesai;
  final String? lokasi;
  final String? linkMaps;
  final double totalBiaya;
  final String status;
  final String? catatan;
  final List<Dance> dances;

  Booking({
    this.id,
    required this.clientId,
    this.client,
    required this.jenisAcara,
    required this.tanggal,
    this.jamMulai,
    this.jamSelesai,
    this.lokasi,
    this.linkMaps,
    this.totalBiaya = 0,
    this.status = 'menunggu',
    this.catatan,
    this.dances = const [],
  });

  static String? _hm(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    clientId: json['client_id'],
    client: json['client'] != null ? Client.fromJson(json['client']) : null,
    jenisAcara: json['jenis_acara'],
    tanggal: json['tanggal'].toString().substring(0, 10),
    jamMulai: _hm(json['jam_mulai']),
    jamSelesai: _hm(json['jam_selesai']),
    lokasi: json['lokasi'],
    linkMaps: json['link_maps'],
    totalBiaya: double.parse(json['total_biaya'].toString()),
    status: json['status'],
    catatan: json['catatan'],
    dances: (json['dances'] as List? ?? [])
        .map((e) => Dance.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'jenis_acara': jenisAcara,
    'tanggal': tanggal,
    'jam_mulai': jamMulai,
    'jam_selesai': jamSelesai,
    'lokasi': lokasi,
    'link_maps': linkMaps,
    'total_biaya': totalBiaya,
    'status': status,
    'catatan': catatan,
    'dance_ids': dances.map((d) => d.id).toList(),
  };
}
