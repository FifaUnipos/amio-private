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
      isBinded: json['status'],
      saldo: json['saldo'],
    );
  }
}

class KulasedayaBinding {
  final String nextUrl;
  final bool status;
  final String saldo;
  final String message;

  KulasedayaBinding({
    required this.nextUrl,
    required this.status,
    required this.saldo,
    required this.message,
  });

  factory KulasedayaBinding.fromJson(Map<String, dynamic> json) {
    return KulasedayaBinding(
      nextUrl: json['next_url'] ?? '',
      status: json['status'] ?? false,
      saldo: json['saldo']?.toString() ?? '0',
      message: json['message'] ?? '',
    );
  }
}
