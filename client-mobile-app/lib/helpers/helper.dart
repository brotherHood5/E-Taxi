import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/Auth.dart';
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

  Customer? customer;
  if (prefs.getString('user') != null) {
    customer = Customer.fromJson(prefs.getString('user')!);
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

Future<void> clearPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<Customer?> getMe(String accessToken) async {
  try {
    var res = await Auth.resolveToken(accessToken);
    if (res.statusCode == 200) {
      await saveCredential(
        userJsonEncoded: res.body,
      );
      var data = await getStoredData();
      return data['user'] as Customer;
    }
  } catch (e) {
    print(e);
  }

  return null;
}

Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
  try {
    var res = await Auth.refreshToken(refreshToken);
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

  Customer? user = await getMe(data["accessToken"]);
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
