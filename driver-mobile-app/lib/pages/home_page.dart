import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_eat_ui/theme/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _mapController = MapController.withUserPosition(
    trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ),
  );

  var markerMap = <String, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mapController.listenerMapSingleTapping.addListener(() async {
        var position = _mapController.listenerMapSingleTapping.value;
        if (position != null) {
          await _mapController.addMarker(position,
              markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                  size: 48,
                ),
              ));

          var key = '${position!.latitude}_${position!.longitude}';
          markerMap[key] = markerMap.length.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: getBody(),
    );
  }

  Widget getBody() {
    return OSMFlutter(
      controller: _mapController,
      osmOption: OSMOption(
        userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        zoomOption: ZoomOption(
          initZoom: 12,
          minZoomLevel: 4,
          maxZoomLevel: 14,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
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
      onGeoPointClicked: (geoPoint) {
        var key = '${geoPoint.latitude}_${geoPoint.longitude}';
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
                            Text(
                              'Position ${markerMap[key]}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Text(
                              key,
                            ),
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
      mapIsLoading: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
