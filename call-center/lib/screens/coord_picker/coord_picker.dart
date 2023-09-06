import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:universal_html/html.dart' as html;

import '../../api/socket.dart';
import '../../helper.dart';
import '../../model/BookingReq.dart';
import '../../model/Location.dart';
import '../../model/Staff.dart';
import '../../api/stream_socket.dart';
import 'login.dart';

class CoordSystem extends StatefulWidget {
  static const String route = '/coord-system';
  const CoordSystem({super.key});

  @override
  State<CoordSystem> createState() => _CoordSystemState();
}

StreamSocket<Map<String, dynamic>> streamSocket = StreamSocket();

class _CoordSystemState extends State<CoordSystem> with OSMMixinObserver {
  MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 10.762622, longitude: 106.660172),
    areaLimit: const BoundingBox.world(),
  );

  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();

  String? latErrorText;
  String? lonErrorText;

  final ValueNotifier<Staff?> user = ValueNotifier(null);
  final ValueNotifier<Location?> currResolveLocation = ValueNotifier(null);
  bool _isPickupResolving = false; // Dang phan gia dia chi don
  late Socket _socket;

  ValueNotifier<BookingReq?> currentRequest = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _socket = SocketApi().ins;

    mapController.addObserver(this);
    currentRequest.addListener(() async {
      debugPrint("Current request: ${currentRequest.value}");
      if (currentRequest.value == null && currResolveLocation.value != null) {
        currResolveLocation.value = null;
        _clearInput();
        try {
          await mapController.removeMarker(GeoPoint(
              latitude: currResolveLocation.value!.lat!,
              longitude: currResolveLocation.value!.lon!));
        } catch (e, s) {
          print(s);
        }
      }
    });

    html.window.onUnload.listen((event) async {
      debugPrint("Reload");
      _disconnectSocket();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    _disconnectSocket();
    currResolveLocation.dispose();
    currentRequest.dispose();
    user.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  void _disconnectSocket() {
    if (_socket.connected) {
      _socket.off(SocketEvent.RECEIVE_BOOKING);
      _socket.disconnect(); // Disconnect the socket when the widget is disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget _body = Container(
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
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder(
                        valueListenable: user,
                        builder: (BuildContext context, dynamic value,
                            Widget? child) {
                          if (value == null) {
                            return child!;
                          }
                          return Column(
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
                                  Text(value.fullName,
                                      style: theme.textTheme.bodySmall)
                                ],
                              )
                            ],
                          );
                        },
                        child: const SizedBox.shrink(),
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
                          offset:
                              const Offset(0, 1), // changes position of shadow
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
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              currentRequest.value =
                                  BookingReq.fromMap(snapshot.data!);
                              debugPrint(
                                  "Receive booking: ${currentRequest.toString()}");
                              var pickupAddr = currentRequest.value!.pickupAddr;
                              var destAddr = currentRequest.value!.destAddr;

                              if (!pickupAddr.hasCoordinate()) {
                                _isPickupResolving = true;
                                currResolveLocation.value = pickupAddr;
                              } else if (!destAddr.hasCoordinate()) {
                                currResolveLocation.value = pickupAddr;
                              }
                            }

                            return ValueListenableBuilder(
                              valueListenable: currResolveLocation,
                              builder: (BuildContext context, Location? value,
                                  Widget? child) {
                                TextStyle? labelStyle = theme
                                    .textTheme.bodyMedium
                                    ?.merge(const TextStyle(
                                        fontWeight: FontWeight.bold));
                                String formattedAddress = "";
                                if (value != null) {
                                  List<String?> array = [
                                    value.homeNo,
                                    value.street,
                                    value.ward,
                                    value.district,
                                    value.city
                                  ]
                                      .where((element) =>
                                          element != null && element.isNotEmpty)
                                      .toList();
                                  formattedAddress = array.join(", ");
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Location",
                                        style: theme.textTheme.titleMedium
                                            ?.merge(const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green))),
                                    const SizedBox(height: 4.0),
                                    Text("Home NO.", style: labelStyle),
                                    Text(
                                        value == null ? "" : value.homeNo ?? "",
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4.0),
                                    Text("Street", style: labelStyle),
                                    Text(value == null ? "" : value.street!,
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4.0),
                                    Text("Ward", style: labelStyle),
                                    Text(value == null ? "" : value.ward ?? "",
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4.0),
                                    Text("District", style: labelStyle),
                                    Text(
                                        value == null
                                            ? ""
                                            : value.district ?? "",
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4.0),
                                    Text("City", style: labelStyle),
                                    Text(value == null ? "" : value.city ?? "",
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4.0),
                                    Text("Formatted Address",
                                        style: labelStyle),
                                    Text(formattedAddress,
                                        softWrap: true,
                                        style: theme.textTheme.bodySmall),
                                  ],
                                );
                              },
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
                          const SizedBox(width: 40.0, child: Text("Lat: ")),
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
                                      borderSide:
                                          BorderSide(color: Colors.blueAccent)),
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
                          const SizedBox(width: 40.0, child: Text("Lon: ")),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 8.0),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueAccent)),
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
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: _bookFunc, child: const Text("Booking")),
                    Expanded(
                      child: ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _coordFunc,
                            child: const Text("Coordinate"),
                          ),
                          ElevatedButton(
                            onPressed: _clearInput,
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: OSMFlutter(
                      controller: mapController,
                      mapIsLoading: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      osmOption: OSMOption(
                        isPicker: true,
                        zoomOption: ZoomOption(
                          minZoomLevel: 2.0,
                          maxZoomLevel: 19.0,
                          initZoom: 12,
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

    return Scaffold(
        body: FutureBuilder(
      future: getStoredData(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data as Map<String, dynamic>;
          user.value = data['user'];
          SocketApi.setAuthToken(data['accessToken']);
          SocketApi.init();

          _socket.on(SocketEvent.RECEIVE_BOOKING, (data) {
            streamSocket.addResponse(data);
          });

          return _body;
        }

        if (snapshot.hasError) {
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

  void _clearInput() {
    latController.clear();
    lonController.clear();
  }

  Future<void> _bookFunc() async {
    if (latController.text.isEmpty && lonController.text.isEmpty) return;
    await _coordFunc();

    if (_isPickupResolving) {
      currentRequest.value!.pickupAddr.lat = double.parse(latController.text);
      currentRequest.value!.pickupAddr.lon = double.parse(lonController.text);

      _isPickupResolving = false;
    } else {
      currentRequest.value!.destAddr.lat = double.parse(latController.text);
      currentRequest.value!.destAddr.lon = double.parse(lonController.text);
    }

    if (currentRequest.value!.pickupAddr.hasCoordinate() &&
        currentRequest.value!.destAddr.hasCoordinate()) {
      _socket.emit("call",
          ["coordSystem.resolvedAddress", currentRequest.value?.toMap()]);

      // Clear screen

      currentRequest.value = null;
    } else {
      if (_isPickupResolving) {
        currResolveLocation.value = currentRequest.value!.pickupAddr;
      } else {
        currResolveLocation.value = currentRequest.value!.destAddr;
      }
    }
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {}
  }

  @override
  Future<void> onSingleTap(GeoPoint position) async {
    super.onSingleTap(position);
    debugPrint("Single tab on ${position.latitude} , ${position.longitude}");
    if (currResolveLocation.value == null) return;

    await mapController.changeLocation(position);

    latController.text = position.latitude.toString();
    lonController.text = position.longitude.toString();
  }

  Future<void> _coordFunc() async {
    if (latController.text.isEmpty && lonController.text.isEmpty) return;
    if (currResolveLocation.value == null) return;

    await mapController.changeLocation(GeoPoint(
        latitude: double.parse(latController.text),
        longitude: double.parse(lonController.text)));
  }
}
