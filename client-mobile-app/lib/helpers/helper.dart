import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/AuthService.dart';
import '../api/GeoService.dart';
import '../models/Booking.dart';
import '../models/Customer.dart';

showLoaderDialog(BuildContext context) {
  Dialog alert = const Dialog(
    // The background color
    backgroundColor: Colors.white,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The loading indicator
          CircularProgressIndicator(),
          SizedBox(
            height: 15,
          ),
          // Some text
          Text('Loading...')
        ],
      ),
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<Map<String, dynamic>> getStoredData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  CustomerModel? customer;
  if (prefs.getString('user') != null) {
    customer = CustomerModel.fromJson(prefs.getString('user')!);
  } else {
    customer = null;
  }

  return {
    'user': customer,
    'accessToken': prefs.getString('accessToken'),
    'refreshToken': prefs.getString('refreshToken'),
  };
}

Future<void> saveCredential({
  final String? userJsonEncoded,
  final String? accessToken,
  final String? refreshToken,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.wait([
    userJsonEncoded != null
        ? prefs.setString('user', userJsonEncoded)
        : Future<void>.value(true),
    accessToken != null
        ? prefs.setString('accessToken', accessToken)
        : Future<void>.value(true),
    refreshToken != null
        ? prefs.setString('refreshToken', refreshToken)
        : Future<void>.value(true),
  ]);
}

Future<void> clearCredential() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.wait([
    prefs.remove('user'),
    prefs.remove('accessToken'),
    prefs.remove('refreshToken'),
  ]);
}

Future<CustomerModel?> getMe(String accessToken) async {
  try {
    var res = await AuthService.resolveToken(accessToken);
    if (res.statusCode == 200) {
      await saveCredential(
        userJsonEncoded: res.body,
      );
      var data = await getStoredData();
      return data['user'] as CustomerModel;
    }
  } catch (e) {
    print(e);
  }

  return null;
}

Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
  try {
    var res = await AuthService.refreshToken(refreshToken);
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      await saveCredential(
        accessToken: body["accessToken"],
        refreshToken: body["refreshToken"],
      );
      return {
        'accessToken': body["accessToken"],
        'refreshToken': body["refreshToken"],
      };
    }
  } catch (e) {
    print(e);
  }

  return null;
}

Future<Map<String, dynamic>?> getNewCredential() async {
  var data = await getStoredData();
  if (data["accessToken"] == null) {
    return null;
  }

  CustomerModel? user = await getMe(data["accessToken"]);
  if (user == null) {
    var newTokens = await refreshToken(data["refreshToken"]);
    if (newTokens != null) {
      await getMe(newTokens["accessToken"]);
      return await getStoredData();
    }
  } else {
    return await getStoredData();
  }

  return null;
}

Future<GeoPoint?> getPickupGeoPoint() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encoded = await prefs.getString("pickupGeoPoint");
  if (encoded == null) {
    return null;
  }
  GeoPoint p = GeoPoint.fromMap(jsonDecode(encoded));
  return p;
}

Future<String?> getPickupAddress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("pickupAddress");
}

Future<void> savePickupGeoPoint(GeoPoint point) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final res = await GeoService.reverseGeocode(point.latitude, point.longitude);
  var data = jsonDecode(res.body);
  await prefs.setString("pickupAddress",
      data[0]["formattedAddress"] ?? "${point.latitude}, ${point.longitude}");
  await prefs.setString("pickupGeoPoint", jsonEncode(point.toMap()));
}

Future<void> saveCurrentBooking(BookingModel booking) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("currentBooking", booking.toJson());
}

Future<BookingModel?> getCurrentBooking() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? json = prefs.getString("currentBooking");
  if (json == null) return null;
  return BookingModel.fromJson(json);
}

Future<void> clearCurrentBooking() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("currentBooking");
}
