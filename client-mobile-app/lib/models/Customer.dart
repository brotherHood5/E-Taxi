// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

import 'UserRole.dart';

class Customer {
  String? id;
  String? phoneNumber;
  String? fullName;
  bool phoneNumberVerified = false;
  bool enable = true;
  bool active = true;
  List<String> roles = [UserRole.CUSTOMER];
  DateTime? createdAt;
  DateTime? updatedAt;
  Customer({
    this.id,
    this.phoneNumber,
    this.fullName,
    required this.phoneNumberVerified,
    required this.enable,
    required this.active,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    bool? phoneNumberVerified,
    bool? enable,
    bool? active,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      phoneNumberVerified: phoneNumberVerified ?? this.phoneNumberVerified,
      enable: enable ?? this.enable,
      active: active ?? this.active,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'phoneNumberVerified': phoneNumberVerified,
      'enable': enable,
      'active': active,
      'roles': roles,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['_id'] != null ? map['_id'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      phoneNumberVerified: map['phoneNumberVerified'] as bool,
      enable: map['enable'] as bool,
      active: map['active'] as bool,
      roles: List<String>.from((map['roles'] as List<dynamic>)),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Customer(id: $id, phoneNumber: $phoneNumber, fullName: $fullName, phoneNumberVerified: $phoneNumberVerified, enable: $enable, active: $active, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Customer other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.fullName == fullName &&
        other.phoneNumberVerified == phoneNumberVerified &&
        other.enable == enable &&
        other.active == active &&
        listEquals(other.roles, roles) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        fullName.hashCode ^
        phoneNumberVerified.hashCode ^
        enable.hashCode ^
        active.hashCode ^
        roles.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
