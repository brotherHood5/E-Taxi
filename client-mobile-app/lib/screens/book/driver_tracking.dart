import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/models/Booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/SocketApi.dart';
import '../../models/BookingStatus.dart';

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen>
    with OSMMixinObserver {
  late MapController _controller;
  final MarkerIcon destMarker = MarkerIcon(
    iconWidget: Image.asset(
      "assets/images/dest_marker.png",
      scale: 0.1,
      width: 60,
      height: 60,
      fit: BoxFit.contain,
    ),
  );
  final MarkerIcon pickupMarker = MarkerIcon(
    iconWidget: Image.asset(
      "assets/images/dest_marker.png",
      scale: 0.1,
      color: Colors.red,
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
  late GeoPoint pickupGeo;
  late GeoPoint destGeo;

  @override
  void initState() {
    super.initState();
    getCurrentBooking().then((value) => {
          log("Current Booking: $value", name: "DriverTrackingScreen"),
          _currentBooking = value!,
          pickupGeo = GeoPoint(
              latitude: _currentBooking.pickupAddr!.lat!,
              longitude: _currentBooking.pickupAddr!.lon!),
          destGeo = GeoPoint(
              latitude: _currentBooking.destAddr!.lat!,
              longitude: _currentBooking.destAddr!.lon!),
          _controller = MapController(initPosition: pickupGeo),
          _controller.addObserver(this),
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    _socket.ins.off("booking_updated", _onBookingUpdated);
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
                GeoPoint destAddr = GeoPoint(
                    latitude: snapshot.data!.destAddr!.lat!,
                    longitude: snapshot.data!.destAddr!.lon!);
                return OSMFlutter(
                    controller: _controller,
                    mapIsLoading:
                        const Center(child: CircularProgressIndicator()),
                    osmOption: OSMOption(
                      staticPoints: [
                        StaticPositionGeoPoint(
                            "pickup", pickupMarker, [pickupPoint]),
                        StaticPositionGeoPoint(
                            "destAddr", destMarker, [destAddr]),
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
    await _controller.goToLocation(p);
  }

  void _onBookingUpdated(dynamic data) async {
    if (data == null) {
      return;
    }
    BookingModel req = BookingModel.fromMap(data);
    switch (req.status) {
      case BookingStatus.FAILED:
        EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
        await clearCurrentBooking();
        break;
      case BookingStatus.DONE:
        await clearCurrentBooking();
        await EasyLoading.showInfo("Đã hoàn thành chuyến đi");
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await _controller.drawRoad(pickupGeo, destGeo);
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? driverLocJson = pref.getString("driverLoc");
      if (driverLocJson != null) {
        Map<String, dynamic> driverLoc = jsonDecode(driverLocJson);
        await _updateDriverLocation(GeoPoint(
            latitude: double.parse(driverLoc["lat"].toString()),
            longitude: double.parse(driverLoc["lon"].toString())));
      }
      SocketApi.init();
      _socket.ins.on("booking_updated", _onBookingUpdated);
      _socket.ins.on("driver_update_location", (data) async {
        GeoPoint p = GeoPoint(
            latitude: data["lat"].toDouble(),
            longitude: data["lon"].toDouble());

        await SharedPreferences.getInstance().then((pref) async {
          await pref.setString("driverLoc", jsonEncode(data));
        });
        await _updateDriverLocation(p);
      });
    }
  }
}
