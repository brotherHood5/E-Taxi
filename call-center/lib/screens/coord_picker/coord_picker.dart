import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:web/constant.dart';
import 'package:web/model/BookingReq.dart';

import '../../helper.dart';
import '../../model/Location.dart';
import '../../model/Staff.dart';
import '../../stream_socket.dart';
import 'login.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:universal_html/html.dart' as html;

class CoordSystem extends StatefulWidget {
  static const String route = '/coord-system';
  const CoordSystem({super.key});

  @override
  State<CoordSystem> createState() => _CoordSystemState();
}

StreamSocket streamSocket = StreamSocket();

class _CoordSystemState extends State<CoordSystem> with OSMMixinObserver {
  MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 10.762622, longitude: 106.660172),
    areaLimit: const BoundingBox.world(),
  );

  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();

  String? latErrorText;
  String? lonErrorText;

  late String accessToken;
  late Staff user;
  late IO.Socket _socket;
  bool _isSocketConnected = false;
  bool _isPickupResolving = false; // Dang phan gia dia chi don
  @override
  void initState() {
    super.initState();
    _getInitData();
    mapController.addObserver(this);

    html.window.onUnload.listen((event) async {
      debugPrint("Reload");
      _disconnectSocket();
    });
  }

  @override
  void dispose() {
    debugPrint("Dispose");
    mapController.dispose();
    _disconnectSocket();
    super.dispose();
  }

  var homeNo = "", street = "", city = "", ward = "", district = "";
  BookingReq? currentRequest = null;

  void _initSocket({required String accessToken}) {
    if (_isSocketConnected) return;

    _socket = IO.io(
        SOCKET_URL,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': accessToken})
            .setQuery({"service": "staffs"})
            .build());

    _socket.onConnect((data) {
      _isSocketConnected = true;
      _socket.emit("call", "coordSystem.connect");
    });
    _socket.onConnectError((data) => debugPrint("Connect Error"));
    _socket.onDisconnect((data) => _isSocketConnected = false);

    _socket.on("receive_booking", (data) {
      streamSocket.addResponse(data);
    });

    _socket.connect();
  }

  void _disconnectSocket() {
    debugPrint("Socket Disconnect");
    if (_isSocketConnected) {
      _socket.disconnect(); // Disconnect the socket when the widget is disposed
      _isSocketConnected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget _body() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("My Info",
                                style: theme.textTheme.titleMedium?.merge(
                                    const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green))),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Text("Full Name:",
                                    style: theme.textTheme.bodySmall?.merge(
                                        TextStyle(
                                            fontWeight: FontWeight.bold))),
                                const SizedBox(height: 16.0),
                                Text(user.fullName,
                                    style: theme.textTheme.bodySmall)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: StreamBuilder(
                            stream: streamSocket.getResponse,
                            builder: (BuildContext context,
                                AsyncSnapshot<Map<String, dynamic>> snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                currentRequest =
                                    BookingReq.fromMap(snapshot.data!);
                                debugPrint(
                                    "Receive booking: ${currentRequest.toString()}");
                                addressResolve();
                              } else {
                                homeNo = "";
                                street = "";
                                district = "";
                                city = "";
                                ward = "";
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location",
                                      style: theme.textTheme.titleMedium?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green))),
                                  const SizedBox(height: 4.0),
                                  Text("Home NO.",
                                      style: theme.textTheme.titleSmall?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(homeNo,
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4.0),
                                  Text("Street",
                                      style: theme.textTheme.titleSmall?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(street,
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4.0),
                                  Text("Ward",
                                      style: theme.textTheme.titleSmall?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(ward,
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4.0),
                                  Text("District",
                                      style: theme.textTheme.titleSmall?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(district,
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4.0),
                                  Text("City",
                                      style: theme.textTheme.titleSmall?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(city,
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4.0),
                                  Text("Formatted Address",
                                      style: theme.textTheme.bodyMedium?.merge(
                                          TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Text(
                                      "$homeNo, $street, $ward, $district, $city",
                                      softWrap: true,
                                      style: theme.textTheme.bodySmall),
                                ],
                              );
                            }),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 40.0, child: Text("Lat: ")),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: TextField(
                                controller: latController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                cursorColor: Colors.blueAccent,
                                decoration: InputDecoration(
                                    errorText: latErrorText,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 8.0),
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueAccent)),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide(width: 1.0)),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Container(width: 40.0, child: const Text("Lon: ")),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: TextField(
                                controller: lonController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                cursorColor: Colors.blueAccent,
                                decoration: InputDecoration(
                                    errorText: lonErrorText,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueAccent)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1.0)),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    child: Row(
                      children: [
                        ElevatedButton(
                            onPressed: bookFunc, child: const Text("Booking")),
                        Expanded(
                          child: ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: coordFunc,
                                child: const Text("Coordinate"),
                              ),
                              ElevatedButton(
                                onPressed: clearInput,
                                child: const Text("Clear"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: OSMFlutter(
                        controller: mapController,
                        osmOption: OSMOption(
                          isPicker: true,
                          zoomOption: ZoomOption(
                            minZoomLevel: 2.0,
                            maxZoomLevel: 18.0,
                            initZoom: 10,
                            stepZoom: 2.0,
                          ),
                          userLocationMarker: UserLocationMaker(
                            personMarker: const MarkerIcon(
                              icon: Icon(
                                Icons.location_history_rounded,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                            directionArrowMarker: const MarkerIcon(
                              icon: Icon(
                                Icons.double_arrow,
                                size: 48,
                              ),
                            ),
                          ),
                          roadConfiguration: RoadOption(
                            roadColor: Colors.yellowAccent,
                          ),
                          markerOption: MarkerOption(
                              defaultMarker: const MarkerIcon(
                            icon: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 56,
                            ),
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
        body: FutureBuilder(
      future: _getInitData(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return _body();
        }

        if (snapshot.hasError) {
          showMyDialog(
              title: "Error",
              errMsg: snapshot.error.toString(),
              context: context);
          return const Login();
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    ));
  }

  String validate(String? value, String label) {
    if (value == null || value.isEmpty) {
      return "$label is required";
    }
    if (double.tryParse(value) == null) {
      return "$label must be a number";
    }
    return value;
  }

  void clearInput() {
    latController.clear();
    lonController.clear();
  }

  void addressResolve() {
    var pickupAddr = currentRequest!.pickupAddr;
    var destAddr = currentRequest!.destAddr;
    var currAddr;

    if (pickupAddr.lat == null || pickupAddr.lon == null) {
      _isPickupResolving = true;
      currAddr = pickupAddr;
    } else {
      currAddr = destAddr;
    }

    homeNo = currAddr.homeNo;
    street = currAddr.street;
    district = currAddr.district;
    city = currAddr.city;
    ward = currAddr.ward;
  }

  Future<void> coordFunc() async {
    if (latController.text.isNotEmpty && lonController.text.isNotEmpty) {
      await mapController.changeLocation(GeoPoint(
          latitude: double.parse(latController.text),
          longitude: double.parse(lonController.text)));
    }
  }

  Future<void> bookFunc() async {
    if (currentRequest == null) return;

    debugPrint("Call Booking");
    if (latController.text.isNotEmpty && lonController.text.isNotEmpty) {
      await coordFunc();
      if (_isPickupResolving) {
        currentRequest?.pickupAddr.lat = double.parse(latController.text);
        currentRequest?.pickupAddr.lon = double.parse(lonController.text);

        _isPickupResolving = false;
      } else {
        currentRequest?.destAddr.lat = double.parse(latController.text);
        currentRequest?.destAddr.lon = double.parse(lonController.text);
      }

      if (currentRequest!.pickupAddr.hasCoordinate() &&
          currentRequest!.destAddr.hasCoordinate()) {
        _socket.emit(
            "call", ["coordSystem.resolvedAddress", currentRequest?.toMap()]);

        // Clear screen
        currentRequest = null;
        streamSocket.addResponse({});
        clearInput();
      } else {
        streamSocket.addResponse(currentRequest!.toMap());
      }
    }
  }

  Future<bool> _getInitData() async {
    Map<String, dynamic> data = await getStoredData();
    accessToken = data['accessToken'];
    user = data['user'];
    return true;
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      debugPrint("Map Loaded");
      _initSocket(accessToken: accessToken);
    }
  }

  @override
  Future<void> onSingleTap(GeoPoint position) async {
    super.onSingleTap(position);
    debugPrint("Single tab on ${position.latitude} , ${position.longitude}");

    await mapController.changeLocation(position);

    latController.text = position.latitude.toString();
    lonController.text = position.longitude.toString();
  }
}
