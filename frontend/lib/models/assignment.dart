class NeedRole {
  final int roleId;
  final String namaPeran;
  final int jumlah;
  NeedRole({
    required this.roleId,
    required this.namaPeran,
    required this.jumlah,
  });

  factory NeedRole.fromJson(Map<String, dynamic> j) => NeedRole(
    roleId: j['role_id'],
    namaPeran: j['nama_peran'],
    jumlah: j['jumlah'],
  );
}

class AssignedMember {
  final int memberId;
  final int roleId;
  AssignedMember({required this.memberId, required this.roleId});

  factory AssignedMember.fromJson(Map<String, dynamic> j) =>
      AssignedMember(memberId: j['member_id'], roleId: j['role_id']);
}

class DanceLineup {
  final int bookingDanceId;
  final String namaTari;
  final List<NeedRole> kebutuhan;
  final List<AssignedMember> assignments;

  DanceLineup({
    required this.bookingDanceId,
    required this.namaTari,
    required this.kebutuhan,
    required this.assignments,
  });

  factory DanceLineup.fromJson(Map<String, dynamic> j) => DanceLineup(
    bookingDanceId: j['booking_dance_id'],
    namaTari: j['dance']['nama_tari'],
    kebutuhan: (j['kebutuhan'] as List)
        .map((e) => NeedRole.fromJson(e))
        .toList(),
    assignments: (j['assignments'] as List)
        .map((e) => AssignedMember.fromJson(e))
        .toList(),
  );
}
