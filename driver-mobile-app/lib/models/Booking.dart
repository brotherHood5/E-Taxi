// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'Address.dart';
import 'Customer.dart';
import 'Driver.dart';

class BookingModel {
  String? id;
  String? phoneNumber;
  String? customerId;
  CustomerModel? customer;
  String? driverId;
  DriverModel? driver;
  String? vehicleType;
  AddressModel? pickupAddr;
  AddressModel? destAddr;
  String? status;
  String? price;
  String? distance;
  bool inApp = true;
  DateTime? createdAt;
  DateTime? updatedAt;
  BookingModel({
    this.id,
    this.phoneNumber,
    this.customerId,
    this.customer,
    this.driverId,
    this.driver,
    this.vehicleType,
    this.pickupAddr,
    this.destAddr,
    this.status,
    this.price,
    this.distance,
    required this.inApp,
    this.createdAt,
    this.updatedAt,
  });

  BookingModel copyWith({
    String? id,
    String? phoneNumber,
    String? customerId,
    CustomerModel? customer,
    String? driverId,
    DriverModel? driver,
    String? vehicleType,
    AddressModel? pickupAddr,
    AddressModel? destAddr,
    String? status,
    String? price,
    String? distance,
    bool? inApp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      vehicleType: vehicleType ?? this.vehicleType,
      pickupAddr: pickupAddr ?? this.pickupAddr,
      destAddr: destAddr ?? this.destAddr,
      status: status ?? this.status,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      inApp: inApp ?? this.inApp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'phoneNumber': phoneNumber,
      'customerId': customerId,
      'customer': customer?.toMap(),
      'driverId': driverId,
      'driver': driver?.toMap(),
      'vehicleType': vehicleType,
      'pickupAddr': pickupAddr?.toMap(),
      'destAddr': destAddr?.toMap(),
      'status': status,
      'price': price,
      'distance': distance,
      'inApp': inApp,
      'createdAt': createdAt?.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      customerId:
          map['customerId'] != null ? map['customerId'] as String : null,
      customer: map['customer'] != null
          ? CustomerModel.fromMap(map['customer'] as Map<String, dynamic>)
          : null,
      driverId: map['driverId'] != null ? map['driverId'] as String : null,
      driver: map['driver'] != null
          ? DriverModel.fromMap(map['driver'] as Map<String, dynamic>)
          : null,
      vehicleType:
          map['vehicleType'] != null ? map['vehicleType'] as String : null,
      pickupAddr: map['pickupAddr'] != null
          ? AddressModel.fromMap(map['pickupAddr'] as Map<String, dynamic>)
          : null,
      destAddr: map['destAddr'] != null
          ? AddressModel.fromMap(map['destAddr'] as Map<String, dynamic>)
          : null,
      status: map['status'] != null ? map['status'] as String : null,
      price: map['price'] != null ? map['price'] as String : null,
      distance: map['distance'] != null ? map['distance'] as String : null,
      inApp: map['inApp'] as bool,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) =>
      BookingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingModel(id: $id, phoneNumber: $phoneNumber, customerId: $customerId, customer: $customer, driverId: $driverId, driver: $driver, vehicleType: $vehicleType, pickupAddr: $pickupAddr, destAddr: $destAddr, status: $status, price: $price, distance: $distance, inApp: $inApp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant BookingModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.customerId == customerId &&
        other.customer == customer &&
        other.driverId == driverId &&
        other.driver == driver &&
        other.vehicleType == vehicleType &&
        other.pickupAddr == pickupAddr &&
        other.destAddr == destAddr &&
        other.status == status &&
        other.price == price &&
        other.distance == distance &&
        other.inApp == inApp &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        customerId.hashCode ^
        customer.hashCode ^
        driverId.hashCode ^
        driver.hashCode ^
        vehicleType.hashCode ^
        pickupAddr.hashCode ^
        destAddr.hashCode ^
        status.hashCode ^
        price.hashCode ^
        distance.hashCode ^
        inApp.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
