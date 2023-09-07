import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'model/Staff.dart';

Future<Map<String, dynamic>?> getStoredData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var user = prefs.getString('user');
  if (user == null) {
    return null;
  }
  Staff staff = Staff.fromMap(jsonDecode(user));

  return {
    'user': staff,
    'accessToken': prefs.getString('accessToken'),
    'refreshToken': prefs.getString('refreshToken'),
  };
}

Future<String?> getRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refreshToken');
}

Future<String?> refreshToken() async {
  final res =
      await http.post(Uri.parse("$BASE_URL/staffs/refresh-token"), body: {
    'token': await getRefreshToken(),
  });
  if (res.statusCode == 200) {
    var json = jsonDecode(res.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', json['accessToken']);
    await prefs.setString('refreshToken', json['refreshToken']);

    return json['accessToken'];
  }

  return null;
}

Future<void> showMyDialog(
    {required String title,
    required String errMsg,
    required BuildContext context}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(errMsg),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
