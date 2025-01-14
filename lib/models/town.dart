class Town {
  final String id;
  final String name;
  final String? region;

  Town({
    required this.id,
    required this.name,
    this.region,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
    };
  }
}
