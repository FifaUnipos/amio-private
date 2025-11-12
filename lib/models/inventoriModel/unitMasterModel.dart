class Unit {
  final int id;
  final String name;
  final String abbreviation;
  final String type;

  Unit({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.type,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
