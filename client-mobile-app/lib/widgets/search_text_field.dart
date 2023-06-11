import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField(
      {super.key, this.onChanged, this.onSubmitted, this.hintText});
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search',
          hintStyle: TextStyle(color: Colors.white),
          fillColor: Colors.red,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.orange,
          ),
        ),
        style: TextStyle(
          color: Colors.orange,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
