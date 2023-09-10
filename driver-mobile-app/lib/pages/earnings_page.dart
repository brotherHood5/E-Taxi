import 'package:flutter/material.dart';
import 'package:grab_eat_ui/theme/colors.dart';

class EarningsPage extends StatefulWidget {
  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
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
        "Earnings Page",
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
      ),
    );
  }
}
