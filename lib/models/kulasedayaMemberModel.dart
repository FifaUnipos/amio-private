class KulasedayaMember {
  final String memberCode;
  final String nama;
  final String isBinded;
  final String saldo;

  KulasedayaMember({
    required this.memberCode,
    required this.nama,
    required this.isBinded,
    required this.saldo,
  });

  factory KulasedayaMember.fromJson(Map<String, dynamic> json) {
    return KulasedayaMember(
      memberCode: json['member_code'],
      nama: json['nama'],
      isBinded: json['is_binded'],
      saldo: json['saldo'],
    );
  }
}
