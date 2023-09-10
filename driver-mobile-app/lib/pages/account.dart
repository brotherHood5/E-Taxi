import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grab_eat_ui/api/AuthService.dart';
import 'package:grab_eat_ui/api/SocketApi.dart';
import 'package:grab_eat_ui/models/Driver.dart';
import 'package:grab_eat_ui/pages/auth/login.dart';
import 'package:grab_eat_ui/widgets/ProfileMenuWidget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../utils/helper.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late DriverModel user;

  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).primaryColor;

    onLogout() async {
      try {
        await AuthService.logout();
        SocketApi.disconnect();
      } catch (e) {
        EasyLoading.showError(e.toString());
        return;
      }
      await clearCredential();
      await Future.delayed(Duration(milliseconds: 500));
      await Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }

    Widget _body = FutureBuilder(
        future: getStoredData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data?["user"] as DriverModel;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),

                    /// -- IMAGE
                    GestureDetector(
                      onTap: () {
                        debugPrint("edit profile");
                      },
                      child: Container(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: const Image(
                                    image:
                                        AssetImage("assets/images/profile.png"),
                                  )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                    border: Border.all(color: iconColor)),
                                child: const Icon(
                                  LineAwesomeIcons.alternate_pencil,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.fullName == null ? "Nguyễn Văn A" : user.fullName!,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 20),

                    /// -- BUTTON
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text("Chỉnh sửa",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),

                    /// -- MENU
                    ProfileMenuWidget(
                      title: "${user.phoneNumber}",
                      icon: Icon(
                        LineAwesomeIcons.phone,
                        color: iconColor,
                      ),
                    ),
                    Builder(builder: (context) {
                      const vehicleTypeMap = {
                        "2": "Xe máy",
                        "4": "Xe 4 chỗ",
                        "7": "Xe 7 chỗ"
                      };
                      const iconMap = {
                        "2": LineAwesomeIcons.motorcycle,
                        "4": LineAwesomeIcons.car,
                        "7": LineAwesomeIcons.car,
                      };
                      return ProfileMenuWidget(
                        title: "${vehicleTypeMap[user.vehicleType]}",
                        icon: Icon(
                          iconMap[user.vehicleType],
                          color: iconColor,
                        ),
                      );
                    }),
                    const Divider(),
                    const SizedBox(height: 10),
                    ProfileMenuWidget(
                      title: "Cài đặt",
                      icon: Icon(
                        LineAwesomeIcons.cog,
                        color: iconColor,
                      ),
                      endIcon: true,
                    ),
                    InkWell(
                      onTap: () => onLogout(),
                      child: ProfileMenuWidget(
                        title: "Đăng xuất",
                        icon: Icon(
                          LineAwesomeIcons.alternate_sign_out,
                          color: iconColor,
                        ),
                        textColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    return Scaffold(body: _body);
  }
}
