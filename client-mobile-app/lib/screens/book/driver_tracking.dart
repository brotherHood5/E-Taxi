import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/models/Booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GeoPoint? _lastKnownDriverLocation = null;
  late BookingModel _currentBooking;

  @override
  void initState() {
    super.initState();
    _socket.ins.off("driver_update_location");

    getCurrentBooking().then((value) => {
          _currentBooking = value!,
          _controller = MapController(
              initPosition: GeoPoint(
                  latitude: _currentBooking.pickupAddr!.lat!,
                  longitude: _currentBooking.pickupAddr!.lon!)),
          _controller.addObserver(this),
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    _socket.ins.off("driver_update_location");
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
                        roadColor: Colors.green,
                        zoomInto: true,
                      ),
                      showZoomController: true,
                      zoomOption: const ZoomOption(
                          initZoom: 15, minZoomLevel: 2, maxZoomLevel: 19),
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

  Future<void> _updateDriverLocation(GeoPoint p) async {
    if (_lastKnownDriverLocation != null) {
      await _controller.removeMarker(_lastKnownDriverLocation!);
    }

    _lastKnownDriverLocation = p;
    await _controller.addMarker(p, markerIcon: driverMarker);
    await _controller.removeLastRoad();
    RoadInfo roadInfo = await _controller.drawRoad(
      p,
      GeoPoint(
          latitude: _currentBooking.pickupAddr!.lat!,
          longitude: _currentBooking.pickupAddr!.lon!),
      roadType: RoadType.car,
    );
    print("${roadInfo.distance}km");
    print("${roadInfo.duration}sec");
    print("${roadInfo.instructions}");
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    print("MAP IS LOADED");
    if (isReady) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? driverLocJson = pref.getString("driverLoc");
      if (driverLocJson != null) {
        print("driverLocJson");
        print(driverLocJson);
        Map<String, dynamic> driverLoc = jsonDecode(driverLocJson);
        await _updateDriverLocation(GeoPoint(
            latitude: double.parse(driverLoc["lat"]),
            longitude: double.parse(driverLoc["lon"])));
      }
      _socket.ins.on("driver_update_location", (data) async {
        print("driver_update_location");
        print(data);
        GeoPoint p = GeoPoint(
            latitude: data["lat"].toDouble(),
            longitude: data["lon"].toDouble());
        await _updateDriverLocation(p);
      });
    }
  }
}
