class Member {
  final int? id;
  final String nama;
  final String? noHp;
  final bool statusAktif;

  Member({this.id, required this.nama, this.noHp, this.statusAktif = true});

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'],
        nama: json['nama'],
        noHp: json['no_hp'],
        statusAktif: json['status_aktif'] == true || json['status_aktif'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'no_hp': noHp,
        'status_aktif': statusAktif,
      };
}