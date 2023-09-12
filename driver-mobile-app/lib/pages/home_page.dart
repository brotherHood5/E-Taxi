import 'dart:async';
import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_eat_ui/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';

import '../api/SocketApi.dart';
import '../models/Booking.dart';
import '../utils/app_constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with OSMMixinObserver {
  late MapController _mapController;
  late Socket _socket;
  BookingModel? _currBookingRequest;
  ValueNotifier<BookingModel?> _acceptedBook = ValueNotifier(null);
  late StreamSubscription<Position> positionStream;
  late StreamController<int> _events;
  Timer? _cancelTimer;
  int _counter = 0;
  var _isShowButton = false.obs;
  var _isPickupDoneButton = false.obs;
  var _isFinishButton = false.obs;
  var _isMapLoading = true.obs;
  Map<String, GeoPoint> _points = Map();

  @override
  void initState() {
    super.initState();
    _events = new StreamController<int>.broadcast();
    _mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
        enableTracking: true,
        unFollowUser: true,
      ),
    );

    _mapController.addObserver(this);
    _acceptedBook.addListener(onLoadCurrBooking);
  }

  @override
  void dispose() {
    log("Dispose", name: "Home Page");
    try {
      _socket.off(SocketEvent.BOOKING_FOUND);
    } catch (e) {}
    try {
      positionStream.cancel();
    } catch (e) {}
    _cancelTimer?.cancel();
    _events.close();
    _acceptedBook.dispose();
    _mapController.dispose();
    _isShowButton.close();
    _isPickupDoneButton.close();
    _isFinishButton.close();
    _isMapLoading.close();
    _currBookingRequest = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget getMap() {
      return OSMFlutter(
        controller: _mapController,
        mapIsLoading: const Center(
          child: CircularProgressIndicator(),
        ),
        osmOption: OSMOption(
          showDefaultInfoWindow: false,
          showZoomController: true,
          zoomOption: ZoomOption(
            initZoom: 15,
            minZoomLevel: 10,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              iconWidget: Image.asset(
                "assets/images/direction_car.png",
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            directionArrowMarker: MarkerIcon(
              iconWidget: Image.asset(
                "assets/images/direction_car.png",
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          roadConfiguration: const RoadOption(
              roadColor: Colors.green,
              roadWidth: 50,
              roadBorderWidth: 20,
              zoomInto: false,
              roadBorderColor: Colors.black),
          markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.black,
                size: 48,
              ),
            ),
          ),
        ),
        onGeoPointClicked: (geoPoint) {
          var key = "${geoPoint.latitude}-${geoPoint.longitude}";
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Thông tin khách hàng',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              const Divider(
                                thickness: 1,
                              ),
                              if (key ==
                                  "${_acceptedBook.value!.pickupAddr!.lat}-${_acceptedBook.value!.pickupAddr!.lon}")
                                Text("Điểm đón",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))
                              else
                                Text("Điểm đến",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              const SizedBox(height: 8),
                              if (_acceptedBook.value?.inApp != null) ...[
                                Text(
                                    'Tên: ${_acceptedBook.value!.customer?.fullName}'),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                  'Số điện thoại: ${_acceptedBook.value!.phoneNumber!}'),
                              const SizedBox(height: 8),
                              Text(
                                  "Điểm đón: ${_acceptedBook.value!.pickupAddr!.lat!}-${_acceptedBook.value!.pickupAddr!.lon!}"),
                              const SizedBox(height: 8),
                              Text(
                                  "Điểm đến: ${_acceptedBook.value!.destAddr!.lat!}-${_acceptedBook.value!.destAddr!.lon!}"),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.clear),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(
        () => Visibility(
          visible: _isShowButton.value,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 16,
            height: 48,
            child: FloatingActionButton.extended(
              onPressed: _isMapLoading.value
                  ? null
                  : () async {
                      _isMapLoading.value = true;
                      if (_isPickupDoneButton.value == false) {
                        _isPickupDoneButton.value = true;
                        _isFinishButton.value = false;
                        await Future.wait([
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool("isPickup", true);
                            prefs.setBool("isFinish", false);
                          }),
                          _mapController.removeMarker(_points["pickupAddr"]!),
                          _mapController.clearAllRoads()
                        ]);
                        _drawRoadToDest()
                            .then((res) => _isMapLoading.value = false)
                            .catchError((err) => _isMapLoading.value = false);
                      } else if (_isFinishButton.value == false) {
                        try {
                          _socket.emitWithAck("call", [
                            SocketEvent.DRIVER_FINISH,
                            {
                              "_id": _acceptedBook.value?.id,
                            },
                          ], ack: (data) async {
                            log("Finish Booking: ${data}", name: "Home Page");
                            if (!(data is List)) {
                              if (data["code"] != null && data["code"] == 404) {
                                _isMapLoading.value = false;
                                return;
                              }
                            }

                            _isPickupDoneButton.value = true;
                            _isFinishButton.value = true;
                            await Future.wait([
                              _mapController.removeMarker(_points["destAddr"]!),
                              _mapController.clearAllRoads(),
                            ]);
                            clearCurrentBooking()
                                .then((res) => _isMapLoading.value = false)
                                .catchError(
                                    (err) => _isMapLoading.value = false);
                          });
                        } catch (e) {
                          log(e.toString(), name: "Home Page");
                        }
                      }
                    },
              label: Text(
                _isPickupDoneButton.value == false
                    ? "Xác nhận đã đón khách"
                    : _isFinishButton.value == false
                        ? "Xác nhận đã hoàn thành"
                        : "",
                style: TextStyle(fontSize: 18),
              ),
              shape: RoundedRectangleBorder(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          getMap(),
          Obx(
            () => Positioned(
              bottom: _isShowButton.value ? 64 : 0,
              right: 0,
              child: IntrinsicWidth(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        alignment: Alignment.center,
                        icon: Icon(Icons.zoom_in),
                        onPressed: () {
                          _mapController.zoomIn();
                        },
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.black,
                      ),
                      IconButton(
                        alignment: Alignment.center,
                        icon: Icon(Icons.zoom_out),
                        onPressed: () {
                          _mapController.zoomOut();
                        },
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.black,
                      ),
                      IconButton(
                        alignment: Alignment.center,
                        icon: Icon(Icons.my_location),
                        onPressed: () {
                          _mapController.currentLocation();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Draw map
  Future<void> _drawRoadToPickup() async {
    await _mapController.addMarker(_points["pickupAddr"]!,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 48,
          ),
        ));
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      try {
        if (mounted == false) return;
        var point = _points["pickupAddr"];
        if (point == null) return;
        _mapController.drawRoad(
            GeoPoint(
                latitude: position.latitude, longitude: position.longitude),
            point);
      } on RoadException catch (e) {
        log("Error4: " + e.toString(), name: "Home Page");
      }
    });
  }

  Future<void> _drawRoadToDest() async {
    _mapController.removeMarker(_points["pickupAddr"]!);
    await _mapController.addMarker(_points["destAddr"]!,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 48,
          ),
        ));
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      try {
        if (mounted == false) return;
        var point = _points["destAddr"];
        if (point == null) return;
        _mapController.drawRoad(
            GeoPoint(
                latitude: position.latitude, longitude: position.longitude),
            point);
      } on RoadException catch (e) {
        log("Error3: " + e.toString(), name: "Home Page");
      }
    });
  }

  // Booking Actions
  // ------------------------------------------
  Future<void> _acceptBooking() async {
    _cancelTimer?.cancel();
    Navigator.of(context).pop();
    log("Accept Booking: ${_currBookingRequest?.id}", name: "Home Page");
    try {
      _socket.emitWithAck("call", [
        SocketEvent.DRIVER_ACCEPT,
        _currBookingRequest?.toMap(),
      ], ack: (data) async {
        if (data == null) {
          await clearCurrentBooking();
        }
        if (data is List) {
          log("Accept Booking: ${data}", name: "Home Page");
          await saveCurrentBooking();
          _isPickupDoneButton.value = false;
          _isFinishButton.value = false;
          _acceptedBook.value = _currBookingRequest;
        } else {
          if (data["code"] != null && data["code"] == 500) {
            await clearCurrentBooking();
            if (data["message"] != null) {
              EasyLoading.showError(
                  "Chuyến đi đã có người chấp nhận hoặc bị huỷ ");
            }
          }
          log("Accept Booking: ${data}", name: "Home Page");
        }
      });
    } catch (e) {
      await clearCurrentBooking();
      log(e.toString(), error: e, name: "Home Page");
    }
  }

  Future<void> _cancelBookingRequest() async {
    _cancelTimer?.cancel();
    initSocketConnect();
    Navigator.pop(context);
  }
  // ------------------------------------------

  // Save current booking to shared preferences
  // ------------------------------------------
  Future<void> saveCurrentBooking() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString("current_booking", _currBookingRequest!.toJson());
      prefs.setBool("isPickup", false);
      prefs.setBool("isFinish", false);
    });
  }

  Future<void> clearCurrentBooking() async {
    _isShowButton.value = false;
    _acceptedBook.value = null;
    _points.clear();
    initSocketConnect();
    Future.wait([
      SharedPreferences.getInstance().then((value) {
        value.remove("current_booking");
        value.remove("isPickup");
        value.remove("isFinish");
      }),
      _mapController.currentLocation(),
    ]);
  }

  Future<BookingModel?> getSavedCurrentBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("current_booking");
    _isPickupDoneButton.value = prefs.getBool("isPickup") ?? false;
    _isFinishButton.value = prefs.getBool("isFinish") ?? false;
    return data != null ? BookingModel.fromJson(data) : null;
  }
  // ------------------------------------------

  Future<void> onLoadCurrBooking() async {
    if (_acceptedBook.value != null) {
      _points["pickupAddr"] = GeoPoint(
          latitude: _acceptedBook.value!.pickupAddr!.lat!,
          longitude: _acceptedBook.value!.pickupAddr!.lon!);
      _points["destAddr"] = GeoPoint(
          latitude: _acceptedBook.value!.destAddr!.lat!,
          longitude: _acceptedBook.value!.destAddr!.lon!);
      _isShowButton.value = true;
      if (mounted == false) return;

      _isMapLoading.value = true;
      try {
        await _mapController.removeLastRoad();
        if (_isPickupDoneButton.value == false) {
          await _drawRoadToPickup();
        } else if (_isFinishButton.value == false) {
          await _drawRoadToDest();
        }
        _isMapLoading.value = false;
      } catch (e) {
      } finally {
        _isMapLoading.value = false;
      }
    }
  }

  void showBookingAcceptDialog() {
    _counter = 10;
    _events.add(_counter);
    _cancelTimer?.cancel();
    _cancelTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      (_counter > 1)
          ? _counter--
          : {
              _cancelBookingRequest(),
            };
      _events.add(_counter);
    });

    AlertDialog dialog = AlertDialog(
        content: StreamBuilder<int>(
            initialData: _counter,
            stream: _events.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                log("StreamBuilder: ${snapshot.data}", name: "Home Page");
                return Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Thông tin khách hàng',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const Divider(
                      thickness: 1,
                    ),
                    if (_currBookingRequest?.inApp != null) ...[
                      Text('Tên: ${_currBookingRequest!.customer?.fullName}'),
                      const SizedBox(height: 8),
                    ],
                    Text("Số điện thoại: ${_currBookingRequest!.phoneNumber}"),
                    const SizedBox(height: 8),
                    Text(
                        "Điểm đón: ${_currBookingRequest!.pickupAddr!.lat!}-${_currBookingRequest!.pickupAddr!.lon!}"),
                    const SizedBox(height: 8),
                    Text(
                        "Điểm đến: ${_currBookingRequest!.destAddr!.lat!}-${_currBookingRequest!.destAddr!.lon!}"),
                    const SizedBox(height: 8),
                    if (_currBookingRequest?.inApp != null) ...[
                      if (_currBookingRequest?.distance != null) ...[
                        Text("Distance: ${_currBookingRequest?.distance} km"),
                        const SizedBox(height: 8),
                      ],
                      if (_currBookingRequest?.price != null) ...[
                        Text("Price: ${_currBookingRequest?.price} đ"),
                        const SizedBox(height: 8),
                      ]
                    ],
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(height: 8),
                    Text("Thời gian xác nhận còn lại: ${snapshot.data} giây"),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (10 - snapshot.data!) / 10,
                      semanticsLabel:
                          "Thời gian xác nhận còn lại: ${snapshot.data} giây",
                      semanticsValue: snapshot.data!.toString(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: _acceptBooking,
                              child: Text("Chấp nhận")),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: _cancelBookingRequest,
                              child: Text("Huỷ bỏ")),
                        ),
                      ],
                    ),
                  ],
                ));
              }
              return Container();
            }));
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);
  }

  Future<void> onBookingFound(dynamic data) async {
    _socket.off(SocketEvent.BOOKING_FOUND);
    log("Socket booking_found: ${data.runtimeType}", name: "Home Page");
    _currBookingRequest = BookingModel.fromMap(data);
    if (_currBookingRequest != null) {
      showBookingAcceptDialog();
    } else {
      _socket.on(SocketEvent.BOOKING_FOUND, onBookingFound);
    }
  }

  Future<void> onLocationChanged(Position? position) async {
    if (position == null) return;
    log("Update Location: ${position.toString()}", name: "Home Page");
    // Send new location to server
    try {
      _socket.emit("call", [
        SocketEvent.UPDATE_LOCATION,
        {
          "lat": position.latitude,
          "lon": position.longitude,
          ...(_acceptedBook.value != null
              ? {
                  "customerId": _acceptedBook.value!.customerId,
                  "inApp": _acceptedBook.value?.inApp ?? false,
                }
              : {}),
        }
      ]);
    } catch (e) {}

    // Update map
    if (_isMapLoading.value == false) {
      // Redraw road
      if (mounted == false) return;

      try {
        await _mapController.clearAllRoads();
        if (_acceptedBook.value != null) {
          if (_isPickupDoneButton.value == false) {
            await _drawRoadToPickup();
          } else if (_isFinishButton.value == false) {
            await _drawRoadToDest();
          }
        }
      } catch (e) {}
    }
  }

  void initSocketConnect() {
    log("initSocketConnect", name: 'Home Page');
    _socket.on(SocketEvent.BOOKING_FOUND, onBookingFound);
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      _socket.emit("call", [
        "bookingSystem.driverConnected",
        {
          "lat": position.latitude,
          "lon": position.longitude,
        },
      ]);
    });
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await getStoredData().then((data) {
        SocketApi.setAuthToken(data["accessToken"]);
        SocketApi.init();
        _socket = SocketApi().ins;
      });
      _acceptedBook.value = await getSavedCurrentBooking();
      if (_acceptedBook.value == null) {
        initSocketConnect();
      }

      log("Map is ready", name: 'Home Page');
      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(onLocationChanged);
      _isMapLoading.value = false;
    }
  }

  @override
  Future<void> mapRestored() {
    log("Map is restored", name: 'Home Page');
    return super.mapRestored();
  }
}
