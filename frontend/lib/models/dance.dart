import 'role.dart';

class DanceRole {
  final Role role;
  final int jumlah;
  DanceRole({required this.role, required this.jumlah});
}

class Dance {
  final int? id;
  final String namaTari;
  final String? deskripsi;
  final bool statusAktif;
  final List<DanceRole> roles;

  Dance({
    this.id,
    required this.namaTari,
    this.deskripsi,
    this.statusAktif = true,
    this.roles = const [],
  });

  factory Dance.fromJson(Map<String, dynamic> json) => Dance(
    id: json['id'],
    namaTari: json['nama_tari'],
    deskripsi: json['deskripsi'],
    statusAktif: json['status_aktif'] == true || json['status_aktif'] == 1,
    roles: (json['roles'] as List? ?? [])
        .map(
          (e) => DanceRole(
            role: Role.fromJson(e),
            jumlah: int.parse(e['pivot']['jumlah_orang'].toString()),
          ),
        )
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'nama_tari': namaTari,
    'deskripsi': deskripsi,
    'status_aktif': statusAktif,
    'roles': roles
        .map((r) => {'role_id': r.role.id, 'jumlah_orang': r.jumlah})
        .toList(),
  };
}
