import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/socket.dart';
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      final res =
          await http.post(Uri.parse("$BASE_URL/staffs/resolve-token"), body: {
        'token': accessToken,
      });
      if (res.statusCode != 200) {
        var newAccessToken = await refreshToken();
        if (newAccessToken != null) {
          SocketApi.setAuthToken(newAccessToken);
          SocketApi.init();
          return const CoordSystem();
        }
      } else {
        SocketApi.setAuthToken(accessToken);
        SocketApi.init();
        return const CoordSystem();
      }
    }

    return const Login();
  }
}
