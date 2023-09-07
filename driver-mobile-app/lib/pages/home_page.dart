import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_eat_ui/theme/colors.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../api/SocketApi.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with OSMMixinObserver, WidgetsBindingObserver {
  late MapController _mapController;
  late Socket _socket;

  var markerMap = <String, String>{};

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
        enableTracking: true,
        unFollowUser: true,
      ),
    );
    WidgetsBinding.instance!.addObserver(this);
    _mapController.addObserver(this);
  }

  @override
  void dispose() {
    _mapController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    _socket.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        print("AppLifecycleState.resumed");
        break;
      case AppLifecycleState.inactive:
        print("AppLifecycleState.inactive");

        // widget is inactive
        break;
      case AppLifecycleState.paused:
        print("AppLifecycleState.paused");

        // widget is paused
        break;
      case AppLifecycleState.detached:
        print("AppLifecycleState.detached");
        // widget is detached
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
    print(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    Widget getBody() {
      return OSMFlutter(
        controller: _mapController,
        osmOption: OSMOption(
          showZoomController: true,
          userTrackingOption: UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          zoomOption: ZoomOption(
            initZoom: 14,
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
          roadConfiguration: const RoadOption(roadColor: Colors.blueGrey),
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
        // onGeoPointClicked: (geoPoint) {
        //   var key = '${geoPoint.latitude}_${geoPoint.longitude}';
        //   showModalBottomSheet(
        //       context: context,
        //       builder: (context) {
        //         return Card(
        //           child: Padding(
        //             padding: const EdgeInsets.all(8),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 Expanded(
        //                   child: Column(
        //                     mainAxisSize: MainAxisSize.min,
        //                     children: [
        //                       Text(
        //                         'Position ${markerMap[key]}',
        //                         style: TextStyle(
        //                             fontSize: 20,
        //                             fontWeight: FontWeight.bold,
        //                             color: Colors.blue),
        //                       ),
        //                       const Divider(
        //                         thickness: 1,
        //                       ),
        //                       Text(
        //                         key,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: () => Navigator.pop(context),
        //                   child: const Icon(Icons.clear),
        //                 )
        //               ],
        //             ),
        //           ),
        //         );
        //       });
        // },
        mapIsLoading: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: white,
      body: getBody(),
    );
  }

  String? currBookReceive = null;
  Future<void> onBookingFound(dynamic data) async {
    _socket.off("booking_found");
    print("Socket booking_found: ");
    print(data);
    currBookReceive = data;
    if (currBookReceive != null) {
      // socket.emit("call", "bookingSystem.driverAccept", data, (err, res) => {
      // 	console.log("Accepted: ", res);
      // 	if (!res) {
      // 		currBookReceive = null;
      // 		socket.on("booking_found", onBookingFound);
      // 	}
      // });
      // setTimeout(() => {

      // }, 4000);
    }
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      _socket = SocketApi().ins;
      GeoPoint geoPoint = await _mapController.myLocation();
      _socket.on("booking_found", (data) {
        print("Socket booking_found: ");
        print(data);
      });
      _socket.emit("call", [
        "bookingSystem.driverConnected",
        {
          "lat": geoPoint.latitude,
          "lon": geoPoint.longitude,
        },
      ]);
      print("Map is ready");
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   _mapController.listenerMapSingleTapping.addListener(() async {
      //
      //   });
      // });
    }
  }

  @override
  void onSingleTap(GeoPoint position) async {
    // var position = _mapController.listenerMapSingleTapping.value;
    // if (position != null) {
    //   await _mapController.addMarker(position,
    //       markerIcon: const MarkerIcon(
    //         icon: Icon(
    //           Icons.pin_drop,
    //           color: Colors.red,
    //           size: 48,
    //         ),
    //       ));

    //   var key = '${position!.latitude}_${position!.longitude}';
    //   markerMap[key] = markerMap.length.toString();
    // }

    super.onSingleTap(position!);
  }
}
