import 'role.dart';

class Member {
  final int? id;
  final String nama;
  final String? noHp;
  final bool statusAktif;
  final List<Role> roles;

  Member({
    this.id,
    required this.nama,
    this.noHp,
    this.statusAktif = true,
    this.roles = const [],
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'],
    nama: json['nama'],
    noHp: json['no_hp'],
    statusAktif: json['status_aktif'] == true || json['status_aktif'] == 1,
    roles: (json['roles'] as List? ?? []).map((e) => Role.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'no_hp': noHp,
    'status_aktif': statusAktif,
    'role_ids': roles.map((r) => r.id).toList(),
  };
}
