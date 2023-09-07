import 'dart:async';
import 'dart:convert';

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

  late String _vehicleName;
  late BookingModel _booking;
  late NavigatorState _navigator;
  bool _isBooking = false;
  final SocketApi _socket = SocketApi();

  Timer? failTimer;
  void startFailTimer() {
    failTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _isBooking = false;
      });
      EasyLoading.dismiss();
      EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
    });
  }

  StreamController<int> _events = StreamController<int>();

  int _counter = 2;
  Timer? _cancelTimer;
  void _startTimer() {
    EasyLoading.dismiss();

    _counter = 2;
    _events.close();
    _events = StreamController<int>();
    _events.add(_counter);

    if (_cancelTimer != null) {
      _cancelTimer?.cancel();
    }
    _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      (_counter != 1)
          ? _counter--
          : {
              _cancelTimer?.cancel(),
              Navigator.of(context).pop(),
              setState(() {
                _isBooking = true;
              })
            };
      _events.add(_counter);
    });
  }

  @override
  void initState() {
    bool _flag = false;
    super.initState();
    _navigator = Navigator.of(context);
    _socket.ins.on("driver_accepted", (data) async {
      if (_flag) return;
      _flag = true;
      var req = data["booking"];
      var driverLoc = data["driver"];

      print("Driver accepted");
      print(data);

      if (_isBooking) {
        onSuccess(BookingModel.fromMap(req));
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("driverLoc", jsonEncode(driverLoc));
        _isBooking = false;
      }
    });
    _socket.ins.on("booking_updated", (data) async {
      BookingModel req = BookingModel.fromMap(data);
      switch (req.status) {
        // case BookingStatus.ASSIGNED:
        //   onSuccess();
        //   break;
        case BookingStatus.FAILED: // fail
          EasyLoading.showError("Không tìm được tài xế. Thử lại sau");
          _isBooking = false;
          await clearCurrentBooking();
          break;
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
    failTimer?.cancel();
    failTimer = null;
    _events.close();
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
                    _startTimer();
                    var res = await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: _buildCancelReqDialog,
                    );

                    try {
                      if (_isBooking) {
                        EasyLoading.show(
                            status: "Đang đặt xe...",
                            maskType: EasyLoadingMaskType.black,
                            dismissOnTap: false);
                      } else {
                        EasyLoading.showError("Hủy đặt xe thành công");
                        return;
                      }

                      final res = await CustomerService.bookRide(_booking);
                      if (res.statusCode == 200) {
                        startFailTimer();
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
                      EasyLoading.showError("Đặt xe thất bại");
                      await clearCurrentBooking();
                    }
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

  AlertDialog _buildCancelReqDialog(BuildContext context) {
    return AlertDialog(
        content: StreamBuilder(
      stream: _events.stream,
      builder: (context, snapshot) {
        return Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Yêu cầu sẽ được xử lí trong ${snapshot.data} giây?"),
            const SizedBox(height: layoutMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => {
                          _cancelTimer?.cancel(),
                          Navigator.of(context).pop(),
                          setState(() {
                            _isBooking = true;
                          })
                        },
                    child: Text("Đồng ý")),
                const SizedBox(
                  width: layoutSmall,
                ),
                TextButton(
                    onPressed: () {
                      _cancelTimer?.cancel();
                      Navigator.of(context).pop();
                      setState(() {
                        _isBooking = false;
                      });
                    },
                    child: Text("Hủy"))
              ],
            )
          ],
        ));
      },
    ));
  }

  void onSuccess(BookingModel req) async {
    failTimer?.cancel();
    await saveCurrentBooking(req);

    EasyLoading.dismiss();
    _navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const DriverTrackingScreen()));
    // failTimer!.cancel();

    // EasyLoading.removeAllCallbacks();
    // EasyLoading.dismiss();
    // _navigator.pushReplacement(
    //     MaterialPageRoute(builder: (context) => const DriverTrackingScreen()));
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
