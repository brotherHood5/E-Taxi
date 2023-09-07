import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grab_eat_ui/pages/account_page.dart';
import 'package:grab_eat_ui/pages/earnings_page.dart';
import 'package:grab_eat_ui/pages/home_page.dart';
import 'package:grab_eat_ui/pages/inbox_page.dart';
import 'package:grab_eat_ui/theme/colors.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

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
      EarningsPage(),
      InboxPage(),
      AccountPage()
    ];
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List bottomItems = [
      "assets/images/home_icon.svg",
      "assets/images/earnings_icon.svg",
      "assets/images/inbox_icon.svg",
      "assets/images/account_icon.svg"
    ];
    List textItems = ["Home", "Earnings", "Inbox", "Account"];
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
          color: white,
          border: Border(
              top: BorderSide(width: 2, color: black.withOpacity(0.06)))),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(textItems.length, (index) {
            return InkWell(
                onTap: () {
                  selectedTab(index);
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      bottomItems[index],
                      width: 22,
                      color: pageIndex == index ? black : Colors.grey,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      textItems[index],
                      style: TextStyle(
                          fontSize: 10,
                          color: pageIndex == index
                              ? black
                              : black.withOpacity(0.5)),
                    )
                  ],
                ));
          }),
        ),
      ),
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
