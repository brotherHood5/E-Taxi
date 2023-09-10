import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/api/CustomerService.dart';
import 'package:grab_clone/helpers/helper.dart';
import 'package:grab_clone/screens/book/driver_tracking.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/SocketApi.dart';
import '../../constants.dart';
import '../../models/Booking.dart';
import '../../models/Address.dart';
import '../../models/BookingStatus.dart';

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

  late String _vehicleType;
  late BookingModel _booking;
  late NavigatorState _navigator;
  final SocketApi _socket = SocketApi();

  int _counter = 10;
  Timer? _failTimer;
  Timer? _cancelTimer;

  @override
  void initState() {
    super.initState();
    _navigator = Navigator.of(context);

    // Init booking
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

    // Init map
    try {
      _controller = MapController.withPosition(
        initPosition: widget.pickUpGeoPoint,
      );
      _controller.addObserver(this);
    } catch (e) {}

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

    // Init vehicle type
    _vehicleType = () {
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
    _failTimer?.cancel();
    _cancelTimer?.cancel();
    _events.close();
    EasyLoading.removeAllCallbacks();
    _socket.ins.off("booking_updated", _onBookingUpdated);
    _socket.ins.off("driver_accepted");
    super.dispose();
  }

  final StreamController<int> _events = StreamController<int>.broadcast();

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
                    title: Text(_vehicleType),
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
                  onPressed: _bookRide,
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

  void _startFailTimer() {
    _failTimer = Timer(const Duration(seconds: 10), () {
      EasyLoading.dismiss();
      EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
    });
  }

  void _startConfirmTimer() {
    _counter = 10;
    _events.add(_counter);
    _cancelTimer?.cancel();
    _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter > 1)
          ? _counter--
          : {
              _cancelBooking(),
            };
      _events.add(_counter);
    });
  }

  // Server actions and listeners
  // --------------------------
  Future<void> _bookRide() async {
    _startConfirmTimer();
    var isConfirm = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: _buildCancelReqDialog,
    );
    if (isConfirm == null || !isConfirm) return;
    EasyLoading.show(
        status: "Đang đặt xe...",
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    try {
      final res = await CustomerService.bookRide(_booking);
      if (res.statusCode == 200) {
        _startFailTimer();
      } else {
        EasyLoading.showError("Đặt xe thất bại");
      }
    } catch (e) {
      EasyLoading.showError("Đặt xe thất bại. Lỗi server");
    }
  }

  void _onDriverAccepted(dynamic data) async {
    log(data.toString(), name: "Book Ride");

    _socket.ins.off("driver_accepted");
    var req = data["booking"];
    var driverLoc = data["driver"];
    if (data == null || req == null || driverLoc == null) {
      _socket.ins.on("driver_accepted", _onDriverAccepted);
      return;
    }
    _failTimer?.cancel();
    EasyLoading.dismiss();

    try {
      await Future.wait([
        SharedPreferences.getInstance().then((pref) async {
          await pref.setString("driverLoc", jsonEncode(driverLoc));
        }),
        saveCurrentBooking(BookingModel.fromMap(req)),
      ]);
      _navigator.pushReplacement(MaterialPageRoute(
          builder: (context) => const DriverTrackingScreen()));
    } catch (e) {
      _socket.ins.on("driver_accepted", _onDriverAccepted);
    }
  }

  void _onBookingUpdated(dynamic data) async {
    if (data == null) {
      return;
    }
    _failTimer?.cancel();
    BookingModel req = BookingModel.fromMap(data);
    log("Booking updated: ${req.status}", name: "Book Ride");
    switch (req.status) {
      case BookingStatus.FAILED:
        EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
        await clearCurrentBooking();
        break;
    }
  }
  // --------------------------

  // Confirm dialog action
  // --------------------------
  void _confirmBooking() {
    _cancelTimer?.cancel();
    Navigator.of(context).pop(true);
  }

  void _cancelBooking() {
    _cancelTimer?.cancel();
    Navigator.of(context).pop(false);
  }
  // --------------------------

  AlertDialog _buildCancelReqDialog(BuildContext context) {
    return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        actionsPadding: const EdgeInsets.all(0),
        content: StreamBuilder(
          initialData: _counter,
          stream: _events.stream,
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(layoutMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Xác nhận yêu cầu trong ${snapshot.data} giây!",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: layoutMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _confirmBooking,
                          child: const Text("Đồng ý")),
                      const SizedBox(
                        width: layoutSmall,
                      ),
                      TextButton(
                          onPressed: _cancelBooking, child: const Text("Hủy"))
                    ],
                  )
                ],
              ),
            );
          },
        ));
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      if (widget.pickUpGeoPoint == widget.destGeoPoint) {
        await EasyLoading.showError(
            "Điểm đón và điểm đến không được trùng nhau");
        _navigator.pop();
        return;
      }

      // Draw road
      RoadInfo roadInfo = await _controller.drawRoad(
        widget.pickUpGeoPoint,
        widget.destGeoPoint,
        roadType: RoadType.car,
      );
      log("${roadInfo.distance}km", name: "Book Ride");
      log("${roadInfo.duration}sec", name: "Book Ride");
      log("${roadInfo.instructions}", name: "Book Ride");
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
        await EasyLoading.showError("Lỗi tính giá");
        _navigator.pop();
      }
      _socket.ins.on("driver_accepted", _onDriverAccepted);
      _socket.ins.on("booking_updated", _onBookingUpdated);
    }
  }
}
