import 'dart:io';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grab_eat_ui/api/SocketApi.dart';
import 'package:grab_eat_ui/pages/account.dart';
import 'package:grab_eat_ui/pages/home_page.dart';
import 'package:grab_eat_ui/theme/colors.dart';
import 'package:grab_eat_ui/utils/helper.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    getStoredData().then((data) {
      print(data);
      SocketApi.setAuthToken(data?["accessToken"]);
      SocketApi.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    List<Widget> pages = [
      HomePage(),
      Center(
        child: Text(
          "Earnings Page",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      Center(
        child: Text(
          "Inbox Page",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: black),
        ),
      ),
      AccountScreen(),
    ];
    // return IndexedStack(
    //   index: pageIndex,
    //   children: pages,
    // );
    return pages[pageIndex];
  }

  Widget getFooter() {
    List bottomItems = [
      "assets/images/home_icon.svg",
      "assets/images/earnings_icon.svg",
      "assets/images/inbox_icon.svg",
      "assets/images/account_icon.svg"
    ];
    List textItems = ["Trang chủ", "Ví", "Inbox", "Tài khoản"];
    return BottomNavigationBar(
        iconSize: 48,
        unselectedFontSize: 13.0,
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: (i) => setState(() => pageIndex = i),
        items: List.generate(
          bottomItems.length,
          (index) => BottomNavigationBarItem(
              label: textItems[index],
              icon: SvgPicture.asset(
                bottomItems[index],
                width: 22,
                colorFilter: ColorFilter.mode(
                    pageIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    BlendMode.srcIn),
              )),
        ));
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
