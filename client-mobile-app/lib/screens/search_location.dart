import 'package:flutter/material.dart';
import 'package:grab_clone/widgets/search_app_bar.dart';
import 'package:grab_clone/widgets/search_text_field.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  void onSrcChange(String text) {
    // Do something with the received text
    print('Received text: $text');
  }

  void onDesChange(String text) {
    // Do something with the received text
    print('Received text: $text');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      // SearchAppBar(),
    ]));
  }
}
