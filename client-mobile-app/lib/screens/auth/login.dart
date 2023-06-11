import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(
      {super.key, required this.phoneNumber, this.phonePrefix = "+84"});
  final String phoneNumber;
  final String phonePrefix;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int remainTryTimes = passwordTryTimes;
  bool isOtpWrong = false;
  void onOtpCompleted(String pin) async {
    setState(() {});
    debugPrint(pin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: topMarginInWelcomeScreen),
        child: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: layoutMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "password_screen_title".tr(),
                style: theme.textTheme.headlineSmall!.merge(const TextStyle(
                  fontWeight: FontWeight.w600,
                )),
              ),
              const SizedBox(height: layoutSmall),
              Text("password_screen_hint".tr(),
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: layoutSmall),
              Text("${widget.phonePrefix}  ${widget.phoneNumber}",
                  style: TextStyle(
                      color: theme.textTheme.titleMedium!.color,
                      fontSize: theme.textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: layoutXLarge),
              OTPTextField(
                obscureText: true,
                length: passwordLength,
                width: MediaQuery.of(context).size.width,
                fieldWidth: passwordFieldWidth,
                style: const TextStyle(
                  fontSize: 25,
                ),
                textFieldAlignment: MainAxisAlignment.spaceBetween,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: borderRadiusSmall,
                onChanged: (pin) => {},
                onCompleted: onOtpCompleted,
              ),
              if (isOtpWrong) const SizedBox(height: layoutSmall),
              if (isOtpWrong)
                Text(
                  "password_wrong_text".plural(remainTryTimes),
                  style: theme.textTheme.titleMedium!.merge(TextStyle(
                    color: theme.colorScheme.error,
                  )),
                ),
              const SizedBox(height: layoutXXLarge),
              Container(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                    onPressed: () => {},
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        overlayColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.transparent)),
                    child: Text(toBeginningOfSentenceCase(
                        "forgot_password_text".tr())!)),
              )
            ],
          ),
        )),
      ),
    );
  }
}
