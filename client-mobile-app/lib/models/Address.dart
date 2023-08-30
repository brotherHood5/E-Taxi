// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddressModel {
  String? id;
  String? homeNo;
  String? street;
  String? ward;
  String? district;
  String? city;

  double? lat;
  double? lon;
  DateTime? createdAt;
  DateTime? updatedAt;
  AddressModel({
    this.id,
    this.homeNo,
    this.street,
    this.ward,
    this.district,
    this.city,
    this.lat,
    this.lon,
    this.createdAt,
    this.updatedAt,
  });

  AddressModel copyWith({
    String? id,
    String? homeNo,
    String? street,
    String? ward,
    String? district,
    String? city,
    double? lat,
    double? lon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      homeNo: homeNo ?? this.homeNo,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'homeNo': homeNo,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'lat': lat,
      'lon': lon,
      'createdAt': createdAt?.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['_id'] != null ? map['_id'] as String : null,
      homeNo: map['homeNo'] != null ? map['homeNo'] as String : null,
      street: map['street'] != null ? map['street'] as String : null,
      ward: map['ward'] != null ? map['ward'] as String : null,
      district: map['district'] != null ? map['district'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      lat: map['lat'] != null ? map['lat'] as double : null,
      lon: map['lon'] != null ? map['lon'] as double : null,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Address(id: $id, homeNo: $homeNo, street: $street, ward: $ward, district: $district, city: $city, lat: $lat, lon: $lon, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant AddressModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.homeNo == homeNo &&
        other.street == street &&
        other.ward == ward &&
        other.district == district &&
        other.city == city &&
        other.lat == lat &&
        other.lon == lon &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        homeNo.hashCode ^
        street.hashCode ^
        ward.hashCode ^
        district.hashCode ^
        city.hashCode ^
        lat.hashCode ^
        lon.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
