import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

Widget greenIntroWidget() {
  return Container(
    width: Get.width,
    height: Get.height * 0.6,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/mask.png'), fit: BoxFit.cover)),
  );
}
