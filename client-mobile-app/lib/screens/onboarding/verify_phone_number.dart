import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../constants.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen(
      {super.key, required this.phoneNumber, this.phonePrefix = "+84"});
  final String phoneNumber;
  final String phonePrefix;

  @override
  State<VerifyPhoneNumberScreen> createState() => VerifyPhoneNumberState();
}

class VerifyPhoneNumberState extends State<VerifyPhoneNumberScreen> {
  bool isOtpWrong = false;
  bool enabled = false;
  int _secondsRemaining = resendOtpTime;
  Timer? _timer;

  void onOtpCompleted(String pin) async {
    setState(() {
      isOtpWrong = true;
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
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> onVerifyOtp() async {
    setState(() {
      isOtpWrong = false;
    });
    // var res = await Auth.verifyOtp(widget.phoneNumber, otp);
    // if (res.statusCode == 200) {
    //   var body = jsonDecode(res.body);
    //   await saveCredential(
    //     accessToken: body["accessToken"],
    //     refreshToken: body["refreshToken"],
    //   );
    //   Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (context) => const MainScreen()));
    // } else {
    //   setState(() {
    //     isOtpWrong = true;
    //   });
    // }
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
        ? () {
            setState(() {
              _secondsRemaining = resendOtpTime;
              startTimer();
            });
          }
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(top: layoutLarge),
          child: SingleChildScrollView(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: layoutMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "otp_screen_title".tr(),
                  style: theme.textTheme.headlineSmall!.merge(const TextStyle(
                    fontWeight: FontWeight.w600,
                  )),
                ),
                const SizedBox(height: layoutSmall),
                RichText(
                    text: TextSpan(
                        text: "otp_screen_hint_1".tr(),
                        style: theme.textTheme.titleMedium,
                        children: [
                      TextSpan(
                          text:
                              " ${widget.phonePrefix}  ${widget.phoneNumber}.\n",
                          style: TextStyle(
                              color: theme.textTheme.titleMedium!.color,
                              fontSize: theme.textTheme.titleMedium!.fontSize,
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "otp_screen_hint_2".tr(),
                          style: theme.textTheme.titleMedium),
                    ])),
                const SizedBox(height: layoutXLarge),
                OTPTextField(
                  hasError: isOtpWrong,
                  obscureText: false,
                  length: otpLength,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: otpFieldWidth,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textFieldAlignment: MainAxisAlignment.start,
                  spaceBetween: layoutMedium,
                  fieldStyle: FieldStyle.box,
                  outlineBorderRadius: borderRadiusSmall,
                  onChanged: (pin) => {},
                  onCompleted: onOtpCompleted,
                ),
                if (isOtpWrong) const SizedBox(height: layoutSmall),
                if (isOtpWrong)
                  Text(
                    "invalid_otp".tr(),
                    style: theme.textTheme.titleMedium!.merge(TextStyle(
                      color: theme.colorScheme.error,
                    )),
                  ),
                const SizedBox(height: layoutXXLarge),
                Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: onResendOtpBtn,
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          overlayColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.transparent)),
                      child: Text(
                          "${toBeginningOfSentenceCase("resend_otp_text".tr())!}${!enabled ? " (${formatTime(_secondsRemaining)})" : ""}"),
                    )),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
