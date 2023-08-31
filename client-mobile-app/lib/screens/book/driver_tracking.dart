import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/models/Booking.dart';

import '../../api/SocketApi.dart';

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen>
    with OSMMixinObserver {
  late MapController _controller;
  final MarkerIcon pickupMarker = MarkerIcon(
    iconWidget: Image.asset(
      "assets/images/dest_marker.png",
      scale: 0.1,
      width: 60,
      height: 60,
      fit: BoxFit.contain,
    ),
  );
  final MarkerIcon driverMarker = MarkerIcon(
    iconWidget: Image.asset(
      "assets/images/taxi-driver.png",
      scale: 0.1,
      width: 60,
      height: 60,
      fit: BoxFit.contain,
    ),
  );
  final SocketApi _socket = SocketApi();

  @override
  void initState() {
    super.initState();
    print("init state");
    _controller = MapController(initMapWithUserPosition: UserTrackingOption());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FutureBuilder<BookingModel?>(
            future: getCurrentBooking(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                GeoPoint pickupPoint = GeoPoint(
                    latitude: snapshot.data!.pickupAddr!.lat!,
                    longitude: snapshot.data!.pickupAddr!.lon!);
                return OSMFlutter(
                    controller: _controller,
                    mapIsLoading:
                        const Center(child: CircularProgressIndicator()),
                    osmOption: OSMOption(
                      staticPoints: [
                        StaticPositionGeoPoint(
                            "pickup", pickupMarker, [pickupPoint]),
                      ],
                      roadConfiguration: const RoadOption(
                        roadWidth: 30,
                        roadBorderColor: Colors.black,
                        roadBorderWidth: 2,
                        roadColor: Colors.blue,
                        zoomInto: true,
                      ),
                      showZoomController: true,
                      zoomOption: const ZoomOption(
                          initZoom: 13, minZoomLevel: 10, maxZoomLevel: 19),
                    ));
              }
              return const Center(child: CircularProgressIndicator());
            }),
        Positioned(
          top: 40,
          left: 8,
          child: FloatingActionButton.small(
            onPressed: () {
              Navigator.of(context).pop();
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ]),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    print("map is ready");
    if (isReady) {}
  }
}
