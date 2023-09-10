import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grab_eat_ui/pages/root_app.dart';
import 'package:pinput/pinput.dart';

class RoundedWithShadow extends StatefulWidget {
  @override
  State<RoundedWithShadow> createState() => _RoundedWithShadowState();

  @override
  String toStringShort() => "Rounded With Shadow";
}

class _RoundedWithShadowState extends State<RoundedWithShadow> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  login() {
    Get.to(() => RootApp());
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(
          fontSize: 18, color: Color.fromRGBO(70, 69, 66, 1)),
      decoration: BoxDecoration(
        color: Color.fromRGBO(232, 235, 241, 0.37),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(120, 120, 120, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    final cursor = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 19,
        height: 1,
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(137, 146, 160, 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            )
          ],
        ),
      ),
      separator: SizedBox(
        width: 16,
      ),
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.red,
      ),
      validator: (s) {
        if (s == '123456') {
          login();
          return null;
        } else
          return 'Pin is incorrect';
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      onCompleted: (pin) => print(pin),
      showCursor: true,
      cursor: cursor,
    );
  }
}
