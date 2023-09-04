import 'package:flutter/material.dart';
import 'package:grab_eat_ui/utils/app_constants.dart';
import 'package:grab_eat_ui/widgets/text_widget.dart';

Widget loginWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    ),
  );
}
