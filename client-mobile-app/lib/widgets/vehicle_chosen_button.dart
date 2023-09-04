import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/screens/book/book_ride.dart';

import '../constants.dart';
import '../screens/place_picker.dart';

class VehicleChosenButton extends StatefulWidget {
  final String image;
  final String title;
  final String vehicleType;
  const VehicleChosenButton(
      {super.key,
      required this.image,
      required this.title,
      required this.vehicleType});

  @override
  State<VehicleChosenButton> createState() => _VehicleChosenButtonState();
}

class _VehicleChosenButtonState extends State<VehicleChosenButton> {
  late NavigatorState navigator;
  @override
  void initState() {
    super.initState();
    navigator = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            GeoPoint? pickUpGeoPoint = await getPickupGeoPoint();
            if (pickUpGeoPoint == null) {
              EasyLoading.showError(
                "Vui lòng chọn điểm đón trước",
                maskType: EasyLoadingMaskType.black,
                duration: const Duration(seconds: 1),
                dismissOnTap: true,
              );
              return;
            }

            GeoPoint? destGeoPoint = await navigator.push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PlacePicker(),
                transitionDuration: shortDuration,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                }));
            if (destGeoPoint != null) {
              var p1 = await navigator.push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BookRideScreen(
                        vehicleType: widget.vehicleType,
                        destGeoPoint: destGeoPoint,
                        pickUpGeoPoint: pickUpGeoPoint,
                      ),
                  transitionDuration: shortDuration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  }));
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(layoutSmall),
            backgroundColor: theme.primaryColor.withOpacity(0.7),
            foregroundColor: Colors.red,
          ),
          child: Image.asset(
            widget.image,
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(height: layoutSmall),
        Text(widget.title, style: theme.textTheme.bodyMedium)
      ],
    );
  }
}
