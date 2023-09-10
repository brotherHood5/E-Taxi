// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

import 'UserRole.dart';

class DriverModel {
  String? id;
  String? phoneNumber;
  String? fullName;
  String? driverStatus;
  String? vehicleType;
  bool phoneNumberVerified = false;
  bool enable = true;
  bool active = true;
  List<String> roles = [UserRole.DRIVER];
  DateTime? createdAt;
  DateTime? updatedAt;
  DriverModel({
    this.id,
    this.phoneNumber,
    this.fullName,
    this.driverStatus,
    this.vehicleType,
    required this.phoneNumberVerified,
    required this.enable,
    required this.active,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  DriverModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? driverStatus,
    String? vehicleType,
    bool? phoneNumberVerified,
    bool? enable,
    bool? active,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      driverStatus: driverStatus ?? this.driverStatus,
      vehicleType: vehicleType ?? this.vehicleType,
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
      'driverStatus': driverStatus,
      'vehicleType': vehicleType,
      'phoneNumberVerified': phoneNumberVerified,
      'enable': enable,
      'active': active,
      'roles': roles,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      driverStatus:
          map['driverStatus'] != null ? map['driverStatus'] as String : null,
      vehicleType:
          map['vehicleType'] != null ? map['vehicleType'] as String : null,
      phoneNumberVerified: map['phoneNumberVerified'] != null
          ? map['phoneNumberVerified'] as bool
          : true,
      enable: map['enable'] != null ? map['enable'] as bool : true,
      active: map['active'] != null ? map['active'] as bool : true,
      roles: map['roles'] != null
          ? List<String>.from((map['roles'] as List<dynamic>))
          : [UserRole.DRIVER],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverModel.fromJson(String source) =>
      DriverModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Driver(id: $id, phoneNumber: $phoneNumber, fullName: $fullName, driverStatus: $driverStatus, vehicleType: $vehicleType, phoneNumberVerified: $phoneNumberVerified, enable: $enable, active: $active, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant DriverModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.fullName == fullName &&
        other.driverStatus == driverStatus &&
        other.vehicleType == vehicleType &&
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
        driverStatus.hashCode ^
        vehicleType.hashCode ^
        phoneNumberVerified.hashCode ^
        enable.hashCode ^
        active.hashCode ^
        roles.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
