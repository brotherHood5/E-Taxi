import 'package:flutter/material.dart';

class SourceTextField extends StatefulWidget {
  const SourceTextField(
      {super.key,
      this.onChanged,
      this.onSubmitted,
      this.hintText,
      this.backgroundColor,
      this.foregroundColor,
      this.focusedColor,
      this.prefixIcon,
      this.suffixIcon,
      this.isSelected = false});
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? focusedColor;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool isSelected;

  @override
  State<SourceTextField> createState() => _SourceTextFieldState();
}

class _SourceTextFieldState extends State<SourceTextField> {
  bool _isFocused = false;

  final TextEditingController controller = TextEditingController();
  FocusNode _textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.backgroundColor ?? Colors.grey[200]
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          enabled: false,
          focusNode: _textFieldFocusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search',
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            prefixIcon: widget.prefixIcon ?? Icon(Icons.search),
          ),
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
