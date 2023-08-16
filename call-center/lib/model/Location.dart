import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Location {
  String? id;
  String homeNo;
  String street;
  String ward;
  String district;
  String city;
  double? lat;
  double? lon;

  Location({
    this.id,
    required this.homeNo,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    this.lat,
    this.lon,
  });

  bool hasCoordinate() {
    return lat != null && lon != null;
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
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['_id'] != null ? map['_id'] as String : null,
      homeNo: map['homeNo'] as String,
      street: map['street'] as String,
      ward: map['ward'] as String,
      district: map['district'] as String,
      city: map['city'] as String,
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
}
