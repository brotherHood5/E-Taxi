// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'Location.dart';

class BookingReq {
  String? id;
  String vehicleType;
  String phoneNumber;
  String? status;
  Location pickupAddr;
  Location destAddr;

  DateTime? createdAt;
  DateTime? updatedAt;
  BookingReq({
    this.id,
    required this.vehicleType,
    required this.phoneNumber,
    this.status,
    required this.pickupAddr,
    required this.destAddr,
    this.createdAt,
    this.updatedAt,
  });

  BookingReq copyWith({
    String? id,
    String? vehicleType,
    String? phoneNumber,
    String? status,
    Location? pickupAddr,
    Location? destAddr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingReq(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      pickupAddr: pickupAddr ?? this.pickupAddr,
      destAddr: destAddr ?? this.destAddr,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'vehicleType': vehicleType,
      'phoneNumber': phoneNumber,
      'status': status,
      'pickupAddr': pickupAddr.toMap(),
      'destAddr': destAddr.toMap(),
      'createdAt': createdAt?.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }

  factory BookingReq.fromMap(Map<String, dynamic> map) {
    return BookingReq(
      id: map['_id'] != null ? map['_id'] as String : null,
      vehicleType: map['vehicleType'] as String,
      phoneNumber: map['phoneNumber'] as String,
      status: map['status'] != null ? map['status'] as String : null,
      pickupAddr: Location.fromMap(map['pickupAddr'] as Map<String, dynamic>),
      destAddr: Location.fromMap(map['destAddr'] as Map<String, dynamic>),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingReq.fromJson(String source) =>
      BookingReq.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingReq(id: $id, vehicleType: $vehicleType, phoneNumber: $phoneNumber, status: $status, pickupAddr: $pickupAddr, destAddr: $destAddr, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant BookingReq other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.vehicleType == vehicleType &&
        other.phoneNumber == phoneNumber &&
        other.status == status &&
        other.pickupAddr == pickupAddr &&
        other.destAddr == destAddr &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        vehicleType.hashCode ^
        phoneNumber.hashCode ^
        status.hashCode ^
        pickupAddr.hashCode ^
        destAddr.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  bool isValidBookingReq() {
    return vehicleType.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        pickupAddr.isValidAddrReq() &&
        destAddr.isValidAddrReq();
  }
}
