// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:web/model/Location.dart';

class TopAddress {
  String? id;
  String? phoneNumber;
  String? addressId;
  Location? address;
  int? count;
  TopAddress({
    this.id,
    required this.phoneNumber,
    required this.addressId,
    required this.address,
    required this.count,
  });

  TopAddress copyWith({
    String? id,
    String? phoneNumber,
    String? addressId,
    Location? address,
    int? count,
  }) {
    return TopAddress(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressId: addressId ?? this.addressId,
      address: address ?? this.address,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'addressId': addressId,
      'address': address?.toMap(),
      'count': count,
    };
  }

  factory TopAddress.fromMap(Map<String, dynamic> map) {
    return TopAddress(
      id: map['_id'] != null ? map['_id'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      addressId: map['addressId'] != null ? map['addressId'] as String : null,
      address: map['address'] != null
          ? Location.fromMap(map['address'] as Map<String, dynamic>)
          : null,
      count: map['count'] != null ? map['count'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TopAddress.fromJson(String source) =>
      TopAddress.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TopAddress(id: $id, phoneNumber: $phoneNumber, addressId: $addressId, address: $address, count: $count)';
  }

  @override
  bool operator ==(covariant TopAddress other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.addressId == addressId &&
        other.address == address &&
        other.count == count;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        addressId.hashCode ^
        address.hashCode ^
        count.hashCode;
  }
}
