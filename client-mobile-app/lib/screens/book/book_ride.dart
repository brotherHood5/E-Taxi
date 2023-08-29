import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../constants.dart';

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
  late String _vehicleName;

  @override
  void initState() {
    super.initState();
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
          return "Xe taxi";
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
            child: Icon(Icons.arrow_back, color: Colors.black),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: layoutSmall),
              color: Colors.green[50],
              child: ListTile(
                leading: Image.asset("assets/images/motorbike.png",
                    fit: BoxFit.scaleDown),
                title: Text(_vehicleName),
                titleTextStyle: theme.textTheme.titleMedium!.merge(
                    const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                trailing: Text("20.000đ"),
                leadingAndTrailingTextStyle: theme.textTheme.titleMedium!.merge(
                    const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: layoutMedium, vertical: layoutSmall),
              child: ElevatedButton(
                  onPressed: () async {},
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
    }
  }
}
