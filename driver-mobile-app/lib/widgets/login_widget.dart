import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grab_eat_ui/utils/app_constants.dart';
import 'package:grab_eat_ui/widgets/text_widget.dart';

Widget loginWidget(
    CountryCode countryCode, Function onCountryChange, Function onSubmit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textWidget(text: AppConstants.helloNiceToMeetYou),
        textWidget(
            text: AppConstants.getMovingWithETaxi,
            fontSize: 22,
            fontweight: FontWeight.bold),
        const SizedBox(
          height: 40,
        ),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 3,
                  blurRadius: 3,
                )
              ],
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onCountryChange(),
                  child: Container(
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            child: countryCode.flagImage,
                          ),
                        ),
                        textWidget(text: countryCode.dialCode),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        Icon(Icons.keyboard_arrow_down_rounded)
                      ],
                    ),
                  ),
                ),
                flex: 1,
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.black.withOpacity(0.2),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    style: GoogleFonts.poppins(fontSize: 14),
                    onSubmitted: (String? input) => onSubmit(input),
                    autofocus: true,
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.normal),
                        hintText: AppConstants.enterMobileNumber,
                        border: InputBorder.none),
                  ),
                ),
                flex: 3,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 12),
                children: [
                  TextSpan(text: AppConstants.byCreating + " "),
                  TextSpan(
                      text: AppConstants.termsOfService + " ",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  TextSpan(text: "and "),
                  TextSpan(
                      text: AppConstants.privacyPolicy + " ",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
      ],
    ),
  );
}
