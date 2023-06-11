import 'package:flutter/material.dart';
import 'package:grab_clone/widgets/search_text_field.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        height: MediaQuery.of(context).size.height * 0.2,
        color: Colors.red,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: const BackButton(),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(children: [
              Placeholder(
                fallbackHeight: 20,
              )
            ]),
          ),
        ]),
      ),
      Center(
        child: Text("Search Location"),
      ),
    ]));
  }
}
