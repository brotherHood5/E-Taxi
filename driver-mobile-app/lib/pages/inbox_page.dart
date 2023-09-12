import 'package:flutter/material.dart';
import 'package:grab_eat_ui/theme/colors.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
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
        "Inbox Page",
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
      ),
    );
  }
}
