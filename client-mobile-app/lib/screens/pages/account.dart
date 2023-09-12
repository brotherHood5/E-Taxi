import 'package:flutter/material.dart';
import 'package:grab_clone/api/AuthService.dart';
import '../../constants.dart';
import '../../helpers/helper.dart';

import '../../models/Customer.dart';
import '../auth/login.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late CustomerModel user;

  @override
  Widget build(BuildContext context) {
    Widget _body = FutureBuilder(
        future: getStoredData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data?["user"] as CustomerModel;
            return Container(
                margin:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: layoutMedium,
                      right: layoutMedium,
                      top: layoutSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
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
                                            offset: const Offset(4, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
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
                                    user.fullName == null
                                        ? "Nguyễn Văn A"
                                        : user.fullName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]),
                      const SizedBox(
                        height: layoutMedium,
                      ),
                      Text("Số điện thoại: ${user.phoneNumber}"),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              await AuthService.logout();
                              await clearCredential();
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            } catch (e) {}
                          },
                          child: Text("Đăng xuất")),
                    ],
                  ),
                ));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    return Scaffold(body: _body);
  }
}
