import 'package:flutter/material.dart';
import 'package:grab_clone/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Padding(
            padding: const EdgeInsets.only(
                left: layoutMedium, right: layoutMedium, top: layoutSmall),
            child: Column(
              children: [
                Container(
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        debugPrint("edit profile");
                      },
                      child: Container(
                          padding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 100,
                                color: Colors.orange,
                              ),
                              Positioned(
                                right: 8,
                                bottom: 10,
                                height: 32,
                                width: 32,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.2),
                                        spreadRadius: 0,
                                        blurRadius: 5,
                                        offset: Offset(4, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: layoutMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Duong Quang Vinh",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              ],
            ),
          )),
    );
  }
}
