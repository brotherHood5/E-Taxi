import 'package:flutter/material.dart';
import 'package:grab_clone/constants.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({super.key});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFadeVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startFadeAnimation() {
    setState(() {
      if (_isFadeVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      _isFadeVisible = !_isFadeVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: _startFadeAnimation,
            child: AnimatedOpacity(
              opacity: _isFadeVisible ? 1.0 : 0.0,
              duration: shortDuration,
              child: Container(
                margin: const EdgeInsets.only(
                  right: layoutMedium,
                  left: layoutSmall,
                  top: 14,
                  bottom: 14,
                ),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.clear, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
