import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grab_eat_ui/widgets/green_intro.dart';
import 'package:grab_eat_ui/widgets/otp_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  String phoneNumber;
  OtpVerificationPage(this.phoneNumber);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                greenIntroWidget(),
                Positioned(
                  top: 60,
                  left: 30,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            OtpVerificationWidget(),
          ],
        ),
      ),
    );
  }
}
