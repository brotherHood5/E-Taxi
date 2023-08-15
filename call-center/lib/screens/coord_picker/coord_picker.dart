import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:web/constant.dart';

import '../../helper.dart';
import '../../model/Staff.dart';
import 'login.dart';

class CoordSystem extends StatefulWidget {
  static const String route = '/coord-system';

  const CoordSystem({super.key});

  @override
  State<CoordSystem> createState() => _CoordSystemState();
}

class _CoordSystemState extends State<CoordSystem> with OSMMixinObserver {
  MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 14.599512, longitude: 120.984222),
    areaLimit: const BoundingBox.world(),
  );

  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();

  String? latErrorText;
  String? lonErrorText;

  late String accessToken;
  late Staff user;

  @override
  void initState() {
    super.initState();
    mapController.addObserver(this);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  var addressTxt = loremIpsum(words: 60);

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
                        child: Column(
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
                                    TextStyle(fontWeight: FontWeight.bold))),
                            Text(addressTxt,
                                softWrap: true,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4.0),
                            Text("Street",
                                style: theme.textTheme.titleSmall?.merge(
                                    TextStyle(fontWeight: FontWeight.bold))),
                            Text(addressTxt,
                                softWrap: true,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4.0),
                            Text("Province",
                                style: theme.textTheme.titleSmall?.merge(
                                    TextStyle(fontWeight: FontWeight.bold))),
                            Text(addressTxt,
                                softWrap: true,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4.0),
                            Text("City",
                                style: theme.textTheme.titleSmall?.merge(
                                    TextStyle(fontWeight: FontWeight.bold))),
                            Text(addressTxt,
                                softWrap: true,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4.0),
                            Text("Formatted Address",
                                style: theme.textTheme.bodyMedium?.merge(
                                    TextStyle(fontWeight: FontWeight.bold))),
                            Text(addressTxt,
                                softWrap: true,
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
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
                            onPressed: () {}, child: const Text("Booking")),
                        Expanded(
                          child: ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: coordFunc,
                                child: const Text("Coordinate"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    latController.clear();
                                    lonController.clear();
                                  });
                                },
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
                        isPicker: true,
                        controller: mapController,
                        initZoom: 15,
                        stepZoom: 1.0,
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

  Future<void> coordFunc() async {
    if (latController.text.isNotEmpty && lonController.text.isNotEmpty) {
      await mapController.changeLocation(GeoPoint(
          latitude: double.parse(latController.text),
          longitude: double.parse(lonController.text)));
    }
  }

  Future<bool> _getInitData() async {
    Map<String, dynamic> data = await getStoredData();
    accessToken = data['accessToken'];
    user = data['user'];
    _sseSubcribe(
      accessToken: accessToken,
      user: user,
    );

    return true;
  }

  void _sseSubcribe({required String accessToken, required Staff user}) {
    SSEClient.subscribeToSSE(url: COORD_SSE_URL, header: {
      "Authorization": "Bearer $accessToken",
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
    }).listen((event) {
      print('Id: ' + event.id!);
      print('Event: ' + event.event!);
      print('Data: ' + event.data!);
    });
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    debugPrint("Map Loaded");
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
