import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/api/CustomerService.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/screens/book/driver_tracking.dart';

import '../../api/SocketApi.dart';
import '../../constants.dart';
import '../../models/Booking.dart';
import '../../models/Address.dart';

class BookRideScreen extends StatefulWidget {
  final GeoPoint pickUpGeoPoint;
  final GeoPoint destGeoPoint;
  final String vehicleType;

  const BookRideScreen(
      {super.key,
      required this.pickUpGeoPoint,
      required this.destGeoPoint,
      required this.vehicleType});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> with OSMMixinObserver {
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
  late MarkerIcon destinationMarker;

  final ValueNotifier<int> _price = ValueNotifier<int>(0);

  late String _vehicleName;
  late BookingModel _booking;
  late NavigatorState _navigator;
  bool _isBooking = false;
  final SocketApi _socket = SocketApi();

  Timer? cancelTimer;

  void startCancelTimer() {
    cancelTimer = Timer(const Duration(minutes: 1), () {
      setState(() {
        _isBooking = false;
      });
      EasyLoading.removeAllCallbacks();
      EasyLoading.dismiss();
      EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
    });
  }

  @override
  void initState() {
    super.initState();
    _navigator = Navigator.of(context);
    _socket.ins.on("booking_accepted", (data) {
      if (_isBooking) {
        onSuccess();
        _isBooking = false;
      }
    });
    _booking = BookingModel(
      vehicleType: widget.vehicleType,
      pickupAddr: AddressModel(
        lat: widget.pickUpGeoPoint.latitude,
        lon: widget.pickUpGeoPoint.longitude,
      ),
      destAddr: AddressModel(
          lat: widget.destGeoPoint.latitude,
          lon: widget.destGeoPoint.longitude),
    );
    _controller = MapController.withPosition(
      initPosition: widget.pickUpGeoPoint,
    );

    _controller.addObserver(this);

    destinationMarker = MarkerIcon(
      iconWidget: Image.asset(
        widget.vehicleType == "2"
            ? "assets/images/motorbike.png"
            : widget.vehicleType == "4"
                ? "assets/images/taxi.png"
                : "assets/images/van.png",
        scale: 0.1,
        width: 60,
        height: 60,
      ),
    );

    _vehicleName = () {
      switch (widget.vehicleType) {
        case "2":
          return "Xe máy";
        case "4":
          return "Xe 4 chỗ";
        case "7":
          return "Xe 7 chỗ";
        default:
          return "Xe máy";
      }
    }();
  }

  @override
  void dispose() {
    _controller.dispose();
    _price.dispose();
    EasyLoading.removeAllCallbacks();
    cancelTimer?.cancel();
    cancelTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(children: [
        OSMFlutter(
            controller: _controller,
            mapIsLoading: const Center(child: CircularProgressIndicator()),
            osmOption: OSMOption(
              staticPoints: [
                StaticPositionGeoPoint(
                    "pickup", pickupMarker, [widget.pickUpGeoPoint]),
                StaticPositionGeoPoint(
                    "dest", destinationMarker, [widget.destGeoPoint]),
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
            )),
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
      bottomSheet: Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _price,
              builder: (BuildContext context, dynamic value, Widget? child) {
                if (value == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: layoutSmall),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: layoutSmall),
                  color: Colors.green[100],
                  child: ListTile(
                    leading: Image.asset(
                        widget.vehicleType == "2"
                            ? "assets/images/motorbike.png"
                            : widget.vehicleType == "4"
                                ? "assets/images/taxi.png"
                                : "assets/images/van.png",
                        fit: BoxFit.scaleDown),
                    title: Text(_vehicleName),
                    titleTextStyle: theme.textTheme.titleMedium!.merge(
                        const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    trailing: Text("${value}đ"),
                    leadingAndTrailingTextStyle: theme.textTheme.titleMedium!
                        .merge(const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: layoutMedium, vertical: layoutSmall),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (!mounted) return;
                      setState(() {
                        _isBooking = true;
                      });

                      final res = await CustomerService.bookRide(_booking);
                      if (res.statusCode == 200) {
                        await saveCurrentBooking(
                            BookingModel.fromJson(res.body));
                        startCancelTimer();
                        EasyLoading.addStatusCallback((status) async {
                          if (status == EasyLoadingStatus.dismiss) {
                            cancelTimer!.cancel();
                            setState(() {
                              _isBooking = false;
                            });
                            EasyLoading.showError("Hủy đặt xe thành công");
                            // await clearCurrentBooking();
                            try {
                              onSuccess();
                            } catch (error) {
                              print(error);
                            }
                            Future.delayed(const Duration(milliseconds: 10),
                                () {
                              EasyLoading.removeAllCallbacks();
                            });
                          }
                        });
                        EasyLoading.show(
                            status: "Đang đặt xe...",
                            maskType: EasyLoadingMaskType.clear,
                            dismissOnTap: true);
                        return;
                      } else {
                        setState(() {
                          _isBooking = false;
                        });
                        EasyLoading.showError("Đặt xe thất bại");
                        await clearCurrentBooking();
                      }
                    } catch (e) {
                      setState(() {
                        _isBooking = false;
                      });
                      await clearCurrentBooking();
                      EasyLoading.showError("Đặt xe thất bại");
                    }
                    _navigator.pop();
                  },
                  style: ButtonStyle(
                      maximumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 50)),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 50)),
                      elevation: MaterialStateProperty.all<double>(0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadiusSmall),
                      ))),
                  child: Text(
                    "Đặt xe",
                    style: theme.textTheme.titleMedium!.merge(const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void onSuccess() {
    cancelTimer!.cancel();
    EasyLoading.removeAllCallbacks();
    EasyLoading.dismiss();
    _navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const DriverTrackingScreen()));
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      RoadInfo roadInfo = await _controller.drawRoad(
        widget.pickUpGeoPoint,
        widget.destGeoPoint,
        roadType: RoadType.car,
      );
      print("${roadInfo.distance}km");
      print("${roadInfo.duration}sec");
      print("${roadInfo.instructions}");
      try {
        final res = await CustomerService.calculatePrice(
            widget.vehicleType, roadInfo.distance!);
        int? data = jsonDecode(res.body);
        if (data != null) {
          var storedData = await getStoredData();
          _booking.phoneNumber = storedData["user"].phoneNumber;
          _booking.customerId = storedData["user"].id;
          _booking.price = data.toString();
          _booking.distance = roadInfo.distance!.toString();
          _price.value = data;
        }
      } catch (e) {
        EasyLoading.showError("Lỗi tính giá");
        _navigator.pop(context);
      }
    }
  }
}
