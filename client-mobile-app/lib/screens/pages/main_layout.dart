import 'package:flutter/material.dart';
import 'package:grab_clone/screens/pages/home.dart';
import 'package:grab_clone/screens/pages/account.dart';
import 'package:hidable/hidable.dart';

import '../../constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Create scroll controller that will be given to scrollable widget and hidable.
  final ScrollController scrollController = ScrollController();
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeScreen(
        scrollController: scrollController,
      ),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: Hidable(
          controller: scrollController,
          wOpacity: true,
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: BottomNavigationBar(
              iconSize: mediumIcon,
              unselectedFontSize: 13.0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: navigationBarItems,
            ),
          ),
        ));
  }
}
