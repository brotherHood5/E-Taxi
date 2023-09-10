import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grab_eat_ui/theme/colors.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../api/AuthService.dart';
import '../../utils/app_constants.dart';
import 'finish_sign_up.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen(
      {super.key, required this.phoneNumber, this.phonePrefix = "+84"});
  final String phoneNumber;
  final String phonePrefix;

  @override
  State<VerifyOtpScreen> createState() => VerifyPhoneNumberState();
}

class VerifyPhoneNumberState extends State<VerifyOtpScreen> {
  bool isOtpWrong = false;
  bool enabled = false;
  int _secondsRemaining = resendOtpTime;
  Timer? _timer;

  void onOtpCompleted(String pin) async {
    bool success = await onVerifyOtp(pin);
    setState(() {
      isOtpWrong = !success;
      if (isOtpWrong) {
        Future.delayed(
            const Duration(seconds: 3),
            () => {
                  setState(() {
                    isOtpWrong = false;
                  })
                });
      }
    });
    debugPrint(pin);
  }

  @override
  void initState() {
    super.initState();
    try {
      AuthService.reSendOtp(widget.phoneNumber);
    } catch (e) {}
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> onVerifyOtp(String otp) async {
    var res = await AuthService.verifyOtp(widget.phoneNumber, otp);
    if (res.statusCode == 200) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FinishSignUpScreen()));
      return true;
    }
    return false;
  }

  void startTimer() {
    enabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          enabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  String formatTime(int seconds) {
    String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    String remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final VoidCallback? onResendOtpBtn = enabled
        ? () async {
            await AuthService.reSendOtp(widget.phoneNumber);
            setState(() {
              _secondsRemaining = resendOtpTime;
              startTimer();
            });
          }
        : null;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
          child: Column(children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Icon(
                  Icons.arrow_back,
                  color: kPrimaryColor,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  "assets/images/verifyOTP.png",
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "otp_screen_title".tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 30),
            RichText(
                text: TextSpan(
                    text: "otp_screen_hint_1".tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                  TextSpan(
                    text: " ${widget.phonePrefix}  ${widget.phoneNumber}.\n",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "otp_screen_hint_2".tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ])),
            const SizedBox(height: 30),
            OTPTextField(
              hasError: isOtpWrong,
              obscureText: false,
              length: otpLength,
              width: Get.width,
              fieldWidth: (Get.width - (layoutMedium * 2)) / 6 - layoutSmall,
              style: const TextStyle(
                fontSize: 20,
              ),
              textFieldAlignment: MainAxisAlignment.spaceBetween,
              spaceBetween: 0,
              fieldStyle: FieldStyle.box,
              outlineBorderRadius: borderRadiusSmall,
              onChanged: (pin) => {},
              onCompleted: onOtpCompleted,
            ),
            if (isOtpWrong) const SizedBox(height: layoutSmall),
            if (isOtpWrong)
              Text(
                "invalid_otp".tr,
                style: theme.textTheme.titleMedium!.merge(TextStyle(
                  color: theme.colorScheme.error,
                )),
              ),
            const SizedBox(height: layoutXXLarge),
            Container(
                alignment: AlignmentDirectional.center,
                child: TextButton(
                  onPressed: onResendOtpBtn,
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      overlayColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.transparent)),
                  child: Text(
                    "${"resend_otp_text".tr}${!enabled ? " (${formatTime(_secondsRemaining)})" : ""}",
                    style: TextStyle(fontSize: 14),
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}
