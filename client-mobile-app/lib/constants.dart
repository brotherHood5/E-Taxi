import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const topMarginInWelcomeScreen = 150.0;

const minTouchSize = 48.0;

const borderRadiusXSmall = 4.0;
const borderRadiusSmall = 8.0;

const layoutSmall = 8.0;
const layoutMedium = 16.0;
const layoutXMedium = 20.0;
const layoutLarge = 24.0;
const layoutXLarge = 32.0;
const layoutXXLarge = 40.0;

const passwordLength = 6;
const passwordFieldWidth = 50.0;
const passwordTryTimes = 5;

const otpLength = 4;
const otpFieldWidth = 50.0;
const resendOtpTime = 10; // seconds

const smallIcon = 16.0;
const mediumIcon = 24.0;

var baseLoadingColor = Colors.grey[400]!;
var highlightLoadingColor = Colors.grey[200]!;

const shortDuration = Duration(milliseconds: 200);
const mediumDuration = Duration(milliseconds: 400);
const longDuration = Duration(milliseconds: 500);

var navigationBarItems = [
  BottomNavigationBarItem(
    label: "navigation_home_label".tr(),
    icon: const Icon(Icons.motorcycle_sharp),
  ),
  BottomNavigationBarItem(
    label: "navigation_account_label".tr(),
    icon: const Icon(Icons.account_circle_outlined),
  ),
];
