class Role {
  final int? id;
  final String namaPeran;

  Role({this.id, required this.namaPeran});

  factory Role.fromJson(Map<String, dynamic> json) =>
      Role(id: json['id'], namaPeran: json['nama_peran']);

  Map<String, dynamic> toJson() => {'nama_peran': namaPeran};
}
