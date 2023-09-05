class Staff {
  final String id;
  final String fullName;
  final String username;
  final List<dynamic> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Staff({
    required this.id,
    required this.fullName,
    required this.username,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'],
      roles: json['roles'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
