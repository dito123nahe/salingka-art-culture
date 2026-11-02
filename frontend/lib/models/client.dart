class Client {
  final int? id;
  final String nama;
  final String? noWa;
  final String? sumber;

  Client({this.id, required this.nama, this.noWa, this.sumber});

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'],
    nama: json['nama'],
    noWa: json['no_wa'],
    sumber: json['sumber'],
  );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'no_wa': noWa,
    'sumber': sumber,
  };
}
