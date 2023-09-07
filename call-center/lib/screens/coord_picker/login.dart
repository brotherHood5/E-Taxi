import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/screens/coord_picker/coord_picker.dart';

import '../../constant.dart';
import '../../helper.dart';

class Login extends StatefulWidget {
  static const String route = '/coord-system/login';

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure = true;
  final TextEditingController _usernameController =
      TextEditingController(text: "20127665");
  final TextEditingController _passwordController =
      TextEditingController(text: "Vinh1706!");
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf5f5f5),
        body: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 8),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 6),
                child: Container(
                  width: 320,
                  child: _formLogin(),
                ),
              ),
            )
          ],
        ));
  }

  Widget _formLogin() {
    return Column(
      children: [
        Text(
          'Log In',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 30),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            filled: true,
            fillColor: Colors.blueGrey[50],
            labelStyle: TextStyle(fontSize: 12),
            contentPadding: EdgeInsets.only(left: 16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[50]!),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[50]!),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        SizedBox(height: 30),
        TextField(
          controller: _passwordController,
          obscureText: _isObscure,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Password',
            suffixIcon: IconButton(
                icon:
                    Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                }),
            filled: true,
            fillColor: Colors.blueGrey[50],
            labelStyle: TextStyle(fontSize: 12),
            contentPadding: EdgeInsets.only(
              left: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[50]!),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[50]!),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        SizedBox(height: 40),
        RoundedLoadingButton(
          controller: _btnController,
          child: Text("Log In", style: TextStyle(color: Colors.white)),
          onPressed: () async => await _login(),
        ),
      ],
    );
  }

  Future<void> _login() async {
    await http.post(Uri.parse(LOGIN_URL), body: {
      'username': _usernameController.text,
      'password': _passwordController.text,
    }).then((res) async {
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['user']));
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);

        await Future.delayed(Duration(seconds: 1));

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const CoordSystem()));
        _btnController.reset();

        return;
      }
      showMyDialog(
          context: context,
          title: 'Login Failed',
          errMsg: 'Username or password is incorrect. Please try again.');
      _btnController.reset();
    }).catchError((e) {
      showMyDialog(
          context: context,
          title: 'Login Failed',
          errMsg: "Can't connect to server. Please try again.");
      _btnController.reset();
    });
  }
}
