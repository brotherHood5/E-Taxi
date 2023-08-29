import 'package:flutter/material.dart';
import 'package:grab_clone/screens/pages/main_layout.dart';
import 'package:grab_clone/screens/auth/login.dart';
import 'package:grab_clone/screens/auth/verify_otp.dart';

import '../helpers/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<Map<String, dynamic>?> checkCredentials() async {
    var data = await getNewCredential();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final Widget _defaultWidget = Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 90.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/taxi.png',
            fit: BoxFit.scaleDown,
            width: 100.0,
            height: 100.0,
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );

    return FutureBuilder(
        future: checkCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var user = snapshot.data?["user"];
              if (user.phoneNumberVerified) {
                if (user.fullName == null || user.fullName == "") {
                  return const LoginScreen();
                } else {
                  return const MainScreen();
                }
              } else {
                return VerifyOtpScreen(
                  phoneNumber: user.phoneNumber,
                );
              }
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const LoginScreen();
            }
          }

          return _defaultWidget;
        });
  }
}
