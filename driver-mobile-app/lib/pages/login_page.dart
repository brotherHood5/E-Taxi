import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grab_eat_ui/widgets/green_intro.dart';
import 'package:grab_eat_ui/widgets/login_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greenIntroWidget(),
              const SizedBox(
                height: 50,
              ),
              loginWidget()
            ],
          ),
        ),
      ),
    );
  }
}
