import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../helper.dart';
import 'coord_picker.dart';
import 'login.dart';

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAuth(),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const Login();
        }
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  Future<Widget> _checkAuth() async {
    print("Checking auth...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    print("Access Token: ");
    print(accessToken);
    await Future.delayed(Duration(seconds: 1));

    if (accessToken != null) {
      final res =
          await http.post(Uri.parse("$BASE_URL/staffs/resolve-token"), body: {
        'token': accessToken,
      });
      if (res.statusCode != 200) {
        var isSuccess = await refreshToken();
        if (isSuccess) {
          return const CoordSystem();
        }
      } else {
        return const CoordSystem();
      }
    }

    return const Login();
  }
}
