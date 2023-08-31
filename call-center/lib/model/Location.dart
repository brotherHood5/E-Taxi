import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Location {
  String? id;
  String? homeNo;
  String? street;
  String? ward;
  String? district;
  String? city;
  double? lat;
  double? lon;

  Location({
    this.id,
    this.homeNo,
    this.street,
    this.ward,
    this.district,
    this.city,
    this.lat,
    this.lon,
  });

  bool hasCoordinate() {
    return lat != null && lon != null;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'homeNo': homeNo,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'lat': lat,
      'lon': lon,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['_id'] != null ? map['_id'] as String : null,
      homeNo: map['homeNo'] != null ? map['homeNo'] as String : null,
      street: map['street'] != null ? map['street'] as String : null,
      ward: map['ward'] != null ? map['ward'] as String : null,
      district: map['district'] != null ? map['district'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      lat: map['lat'] != null ? map['lat'] as double : null,
      lon: map['lon'] != null ? map['lon'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Location(id: $id, homeNo: $homeNo, street: $street, ward: $ward, district: $district, city: $city, lat: $lat, lon: $lon)';
  }

  Location copyWith({
    String? id,
    String? homeNo,
    String? street,
    String? ward,
    String? district,
    String? city,
    double? lat,
    double? lon,
  }) {
    return Location(
      id: id ?? this.id,
      homeNo: homeNo ?? this.homeNo,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.homeNo == homeNo &&
        other.street == street &&
        other.ward == ward &&
        other.district == district &&
        other.city == city &&
        other.lat == lat &&
        other.lon == lon;
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
        lon.hashCode;
  }

  bool isValidAddrReq() {
    return city != null &&
        city!.isNotEmpty &&
        street != null &&
        street!.isNotEmpty &&
        homeNo != null &&
        homeNo!.isNotEmpty;
  }
}
