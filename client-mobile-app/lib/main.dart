import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:grab_clone/screens/main.dart';
import 'package:grab_clone/screens/auth/login.dart';
import 'package:grab_clone/screens/auth/sign_up.dart';
import 'package:grab_clone/screens/onboarding/verify_phone_number.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'package:grab_clone/screens/onboarding/welcome.dart';
// import 'screens/home.dart';
// import 'screens/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //   if (user == null) {
  //     debugPrint('User is currently signed out!');
  //   } else {
  //     debugPrint('User is signed in!');
  //   }
  // });
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi', 'VN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi', 'VN'),
      startLocale: const Locale('vi', 'VN'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
