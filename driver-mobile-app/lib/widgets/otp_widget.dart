import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grab_eat_ui/utils/app_constants.dart';
import 'package:grab_eat_ui/widgets/pinput_widget.dart';
import 'package:grab_eat_ui/widgets/text_widget.dart';

Widget OtpVerificationWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textWidget(text: AppConstants.phoneVerification),
        textWidget(
            text: AppConstants.enterOtp,
            fontSize: 22,
            fontweight: FontWeight.bold),
        const SizedBox(
          height: 40,
        ),
        RoundedWithShadow(),
        const SizedBox(
          height: 40,
        ),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
              children: [
                TextSpan(text: AppConstants.resendCode + " "),
                TextSpan(
                    text: "10 seconds",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ]),
        ),
      ],
    ),
  );
}
