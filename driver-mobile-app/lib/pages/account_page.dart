import 'package:flutter/material.dart';
import 'package:grab_eat_ui/theme/colors.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
    );
  }

  Widget getBody() {
    return Center(
      child: Text(
        "Account Page",
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
      ),
    );
  }
}
