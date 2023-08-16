// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'Location.dart';

class BookingReq {
  String? id;
  String vehicleType;
  String phoneNumber;
  String status;
  Location pickupAddr;
  Location destAddr;

  DateTime? createdAt;
  DateTime? updatedAt;

  BookingReq(
      {this.id,
      required this.vehicleType,
      required this.phoneNumber,
      required this.status,
      required this.pickupAddr,
      required this.destAddr,
      this.createdAt,
      this.updatedAt});

  @override
  String toString() {
    return 'BookingReq(id: $id, vehicleType: $vehicleType, phoneNumber: $phoneNumber, status: $status, pickupAddr: $pickupAddr, destAddr: $destAddr, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
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
      status: map['status'] as String,
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
}
