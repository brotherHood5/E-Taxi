import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grab_clone/api/Auth.dart';
import 'package:grab_clone/screens/main_layout.dart';
import 'package:grab_clone/screens/onboarding/login.dart';
import 'package:grab_clone/screens/onboarding/sign_up.dart';
import 'package:grab_clone/screens/onboarding/verify_phone_number.dart';

import '../../helpers/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<Map<String, dynamic>?> checkCredentials() async {
    // await clearPreference();
    var data = await getStoredData();
    print("checkCredentials");

    if (data["accessToken"] == null) {
      return null;
    }

    // Check if token is valid
    var res = await Auth.resolveToken(data["accessToken"]);
    if (res.statusCode == 200) {
      return data;
    } else {
      try {
        res = await Auth.refreshToken(data["refreshToken"]);
        if (res.statusCode == 200) {
          var body = jsonDecode(res.body);
          await saveCredential(
            accessToken: body["accessToken"],
            refreshToken: body["refreshToken"],
          );
          return data;
        }
      } catch (e) {
        print(e);
      }
    }

    return null;
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
          print(snapshot.connectionState);
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var user = snapshot.data?["user"];
              if (user.phoneNumberVerified) {
                // return const SignUpScreen();
                return const MainScreen();
              } else {
                return VerifyPhoneNumberScreen(
                  phoneNumber: user.phoneNumber,
                );
              }
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const LoginScreen();
              // return const SignUpScreen();
            }
          }

          return _defaultWidget;
        });
  }
}
