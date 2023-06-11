import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:grab_clone/constants.dart';
import 'package:grab_clone/screens/auth/login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _controller = TextEditingController();

  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    _controller.addListener(() {
      setState(() {
        enabled = _controller.text.isNotEmpty;
      });

      if (_controller.text.length > 10) {
        _controller.text = _controller.text.substring(0, 10);
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
      }
    });

    final VoidCallback? onBtnPressed = enabled
        ? () {
            String phonePrefix = "+84";
            String phoneNumber = _controller.text;
            if (phoneNumber.startsWith("0")) {
              phoneNumber = phoneNumber.replaceFirst("0", "");
            }

            // TODO: Check if phone number is existed in database
            bool isExisted = true;

            if (isExisted) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return LoginScreen(
                    phoneNumber: phoneNumber, phonePrefix: phonePrefix);
              }));
            }
          }
        : null;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: topMarginInWelcomeScreen),
        child: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: layoutMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("welcome_text".tr(), style: theme.textTheme.titleLarge),
              const SizedBox(height: layoutSmall),
              Text("guild_text".tr(), style: theme.textTheme.titleMedium),
              const SizedBox(height: layoutXLarge),
              Text("sdt_text".tr(), style: theme.textTheme.titleSmall),
              const SizedBox(height: layoutSmall),
              TextField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "sdt_hint_text".tr(),
                  border: const OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadiusSmall)),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _controller.clear(),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: layoutXXLarge),
              ElevatedButton(
                  onPressed: onBtnPressed,
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, minTouchSize)),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadiusXSmall),
                      ),
                    ),
                  ),
                  child:
                      Text(toBeginningOfSentenceCase("continue_text".tr())!)),
            ],
          ),
        )),
      ),
    );
  }
}
