import 'dart:convert';

import 'package:web/model/Location.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class TopHistory {
  String? id;
  String phoneNumber;
  Location pickupAddr;
  Location destAddr;
  String status;
  String createdAt;
  String updatedAt;

  TopHistory({
    required this.id,
    required this.phoneNumber,
    required this.pickupAddr,
    required this.destAddr,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  TopHistory copyWith({
    String? id,
    String? phoneNumber,
    Location? pickupAddr,
    Location? destAddr,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return TopHistory(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pickupAddr: pickupAddr ?? this.pickupAddr,
      destAddr: destAddr ?? this.destAddr,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'pickupAddr': pickupAddr.toMap(),
      'destAddr': destAddr.toMap(),
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // factory TopHistory.fromJson(Map<String, dynamic> json) {
  //   return TopHistory(
  //     id: json['_id'],
  //     phoneNumber: json['phoneNumber'],
  //     pickupAddr: Location.fromJson(json['pickupAddr']),
  //     destAddr: Location.fromJson(json['destAddr']),
  //     status: json['status'],
  //     createdAt: json['createdAt'],
  //     updatedAt: json['updatedAt'],
  //   );
  // }

  factory TopHistory.fromMap(Map<String, dynamic> map) {
    return TopHistory(
      id: map['_id'] != null ? map['_id'] as String : null,
      phoneNumber: map['phoneNumber'] as String,
      pickupAddr: Location.fromMap(map['pickupAddr'] as Map<String, dynamic>),
      destAddr: Location.fromMap(map['destAddr'] as Map<String, dynamic>),
      status: map['status'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());
  factory TopHistory.fromJson(String source) =>
      TopHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TopHistory(id: $id, phoneNumber: $phoneNumber, pickupAddr: $pickupAddr, destAddr: $destAddr, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // @override
  // bool operator ==(covariant TopAddress other) {
  //   if (identical(this, other)) return true;

  //   return other.id == id &&
  //       other.phoneNumber == phoneNumber &&
  //       other.addressId == addressId &&
  //       other.address == address &&
  //       other.count == count;
  // }

  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //       phoneNumber.hashCode ^
  //       addressId.hashCode ^
  //       address.hashCode ^
  //       count.hashCode;
  // }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TopHistory &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.pickupAddr == pickupAddr &&
        other.destAddr == destAddr &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
// class TopHistory{
//   String? id;
//   String phoneNumber;
//   String addressId;
//   Location address;
//   int count;
//   TopAddress({
//     this.id,
//     required this.phoneNumber,
//     required this.addressId,
//     required this.address,
//     required this.count,
//   });

//   TopAddress copyWith({
//     String? id,
//     String? phoneNumber,
//     String? addressId,
//     Location? address,
//     int? count,
//   }) {
//     return TopAddress(
//       id: id ?? this.id,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       addressId: addressId ?? this.addressId,
//       address: address ?? this.address,
//       count: count ?? this.count,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'phoneNumber': phoneNumber,
//       'addressId': addressId,
//       'address': address.toMap(),
//       'count': count,
//     };
//   }

//   factory TopAddress.fromMap(Map<String, dynamic> map) {
//     return TopAddress(
//       id: map['_id'] != null ? map['_id'] as String : null,
//       phoneNumber: map['phoneNumber'] as String,
//       addressId: map['addressId'] as String,
//       address: Location.fromMap(map['address'] as Map<String, dynamic>),
//       count: map['count'] as int,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory TopAddress.fromJson(String source) =>
//       TopAddress.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() {
//     return 'TopAddress(id: $id, phoneNumber: $phoneNumber, addressId: $addressId, address: $address, count: $count)';
//   }

//   @override
//   bool operator ==(covariant TopAddress other) {
//     if (identical(this, other)) return true;

//     return other.id == id &&
//         other.phoneNumber == phoneNumber &&
//         other.addressId == addressId &&
//         other.address == address &&
//         other.count == count;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         phoneNumber.hashCode ^
//         addressId.hashCode ^
//         address.hashCode ^
//         count.hashCode;
//   }
// }
