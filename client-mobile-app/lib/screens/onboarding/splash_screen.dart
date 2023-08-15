import 'package:flutter/material.dart';

// import "package:flutter/material.dart";
// import "package:grab_clone/screens/auth/login.dart";

// class CheckAuth extends StatefulWidget {
//   const CheckAuth({super.key});

//   @override
//   State<CheckAuth> createState() => _CheckAuthState();
// }

// class _CheckAuthState extends State<CheckAuth> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // future: _checkAuth(),
//       builder: ((context, snapshot) {
//         if (snapshot.hasError) {
//           // return const LoginScreen();
//         }

//         if (snapshot.hasData) {
//           return snapshot.data as Widget;
//         }

//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       }),
//     );
//   }

//   // Future<Widget> _checkAuth() async {
//   //   print("Checking auth...");
//   //   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   final String? accessToken = prefs.getString('accessToken');
//   //   print("Access Token: ");
//   //   print(accessToken);
//   //   await Future.delayed(Duration(seconds: 1));

//   //   if (accessToken != null) {
//   //     final res =
//   //         await http.post(Uri.parse("$BASE_URL/staffs/resolve-token"), body: {
//   //       'token': accessToken,
//   //     });
//   //     if (res.statusCode != 200) {
//   //       var isSuccess = await refreshToken();
//   //       if (isSuccess) {
//   //         return const CoordSystem();
//   //       }
//   //     } else {
//   //       return const CoordSystem();
//   //     }
//   //   }

//   //   return const Login();
//   // }
// }

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.9],
          colors: [
            Color(0xFFFC5C7D),
            Color(0xFF6A82FB),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 90.0),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.scaleDown,
      ),
    );
  }
}
