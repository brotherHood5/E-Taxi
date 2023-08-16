import 'dart:convert';

import 'package:collection/collection.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Staff {
  String? id;
  String fullName;
  String username;
  List<String> roles;

  DateTime? createdAt;
  DateTime? updatedAt;

  Staff({
    this.id,
    required this.fullName,
    required this.username,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'fullName': fullName,
      'username': username,
      'roles': roles,
      'createdAt': createdAt?.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['_id'] != null ? map['_id'] as String : null,
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      roles: List<String>.from((map['roles'] as List<dynamic>)),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Staff.fromJson(String source) =>
      Staff.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Staff(id: $id, fullName: $fullName, username: $username, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
