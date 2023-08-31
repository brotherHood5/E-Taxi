import 'dart:convert';
// import 'dart:ffi';

// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:web/constant.dart';
import 'package:web/model/BookingReq.dart';
import '../../model/TopAddress.dart';
import '../../model/TopHistory.dart';
import 'bookingForm.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  static const String route = '/dashboard';
  // final Function saveChildCallback;

  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  bool isExpanded = false;

  final BookingFormController _bookingFormController = BookingFormController();
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(-1);

  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    phoneNumber = "0972360214";
  }

  Future<void> _bookRide(BookingReq req) async {
    final res = await http.post(Uri.parse(BOOKCAR_URL),
        headers: {
          "Content-Type": "application/json",
        },
        body: req.toJson());
    if (res.statusCode == 200) {
    } else {
      throw Exception("Error");
    }
  }

  Future<List<TopAddress>> _getTop5Address() async {
    final res = await http.get(
      Uri.parse(TOP5_ADDRESS_URL)
          .replace(queryParameters: {"phoneNumber": "$phoneNumber"}),
    );

    if (res.statusCode == 200) {
      try {
        List jsonRes = json.decode(res.body);
        var data = jsonRes.map((data) => TopAddress.fromMap(data)).toList();
        return data;
      } catch (e) {
        return [];
      }
    } else {
      throw Exception("Error");
    }
  }

  Future<List<TopHistory>> _getTopHistory() async {
    final res = await http.get(
      Uri.parse(BOOKING_HISTORY_URL)
          .replace(queryParameters: {"phoneNumber": phoneNumber}),
    );
    if (res.statusCode == 200) {
      List jsonRes = json.decode(res.body);
      try {
        var data = jsonRes.map((data) => TopHistory.fromMap(data)).toList();
        return data;
      } catch (e) {
        return [];
      }
    } else {
      throw Exception("Error");
    }
  }

  void onPhoneNumberChanged(text) {
    setState(() {
      phoneNumber = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //Let's start by adding the Navigation Rail
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BookingForm(
                            controller: _bookingFormController,
                            onPhoneNumberChanged: onPhoneNumberChanged,
                            // saveChildCallback: submitForm(),
                          ),
                        ),
                        const SizedBox(
                          width: 40.0,
                        ),
                        Expanded(
                          // To make sure DataTable takes up the available space
                          child: FutureBuilder<List<TopAddress>>(
                              future: _getTop5Address(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.grey.shade200),
                                      columns: const [
                                        DataColumn(label: Text("No")),
                                        DataColumn(label: Text("Top address")),
                                        DataColumn(label: Text("Counts")),
                                      ],
                                      rows: List.generate(snapshot.data!.length,
                                          (index) {
                                        var data = snapshot.data![index];

                                        var addr = data.address;
                                        var list = [
                                          addr?.homeNo,
                                          addr?.street,
                                          addr?.ward,
                                          addr?.district,
                                          addr?.city,
                                        ];
                                        var formattedAddr = list.join(", ");
                                        return DataRow(cells: [
                                          DataCell(Text("${index + 1}")),
                                          DataCell(Text(formattedAddr)),
                                          DataCell(Text(data.count.toString())),
                                        ]);
                                      }));
                                }
                                if (snapshot.hasError) {
                                  return DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey.shade200),
                                    columns: const [
                                      DataColumn(label: Text("No")),
                                      DataColumn(label: Text("Top address")),
                                      DataColumn(label: Text("Counts")),
                                    ],
                                    rows: [],
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }),
                        ),
                      ],
                    ),

                    //Now let's set the article section
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // To make sure DataTable takes up the available space
                          child: FutureBuilder<List<TopHistory>>(
                              future: _getTopHistory(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ValueListenableBuilder(
                                    valueListenable: _selectedIndex,
                                    builder: (BuildContext context,
                                        dynamic value, Widget? child) {
                                      return DataTable(
                                          showCheckboxColumn: false,
                                          headingRowColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) =>
                                                      Colors.grey.shade200),
                                          columns: const [
                                            DataColumn(label: Text("No")),
                                            DataColumn(
                                                label: Text("Pickup Addr")),
                                            DataColumn(
                                                label: Text("Dest Addr")),
                                            DataColumn(
                                                label: Text("Booking Time")),
                                          ],
                                          rows: List.generate(
                                              snapshot.data!.length, (index) {
                                            var data = snapshot.data![index];

                                            var pickupAddr = data.pickupAddr;
                                            var pickupAddrList = [
                                              pickupAddr?.homeNo,
                                              pickupAddr?.street,
                                              pickupAddr?.ward,
                                              pickupAddr?.district,
                                              pickupAddr?.city,
                                            ];
                                            var destAddr = data.destAddr;
                                            var destAddrList = [
                                              destAddr?.homeNo,
                                              destAddr?.street,
                                              destAddr?.ward,
                                              destAddr?.district,
                                              destAddr?.city,
                                            ];

                                            return DataRow(
                                                color: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        value == index
                                                            ? Colors
                                                                .orange.shade200
                                                            : Colors.white),
                                                onSelectChanged: (selected) {
                                                  if (selected != null &&
                                                      selected) {
                                                    _selectedIndex.value =
                                                        index;
                                                    _bookingFormController
                                                        .insertBookReq(snapshot
                                                            .data![index]
                                                            .deepCopyWith());
                                                  }
                                                },
                                                cells: [
                                                  DataCell(
                                                      Text("${index + 1}")),
                                                  DataCell(Text(pickupAddrList
                                                      .join(", "))),
                                                  DataCell(Text(
                                                      destAddrList.join(", "))),
                                                  DataCell(Text(
                                                      data.createdAt == null
                                                          ? ""
                                                          : data.createdAt
                                                              .toString()))
                                                ]);
                                          }));
                                    },
                                  );
                                }
                                if (snapshot.hasError) {
                                  return DataTable(
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey.shade200),
                                    columns: const [
                                      DataColumn(label: Text("No")),
                                      DataColumn(label: Text("home No")),
                                      DataColumn(label: Text("Street")),
                                      DataColumn(label: Text("Ward")),
                                      DataColumn(label: Text("District")),
                                      DataColumn(label: Text("City")),
                                    ],
                                    rows: [],
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      var req = _bookingFormController.bookingReq;
                      if (req.isValidBookingReq()) {
                        await _bookRide(req);
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: Text('Success'),
                                  content: Text('Request has been sent'),
                                ));
                        _bookingFormController.clear();
                      } else {
                        await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Please provide all fields'),
                                ));
                      }
                    },
                    child: const Text("Booking")),
                const SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    _bookingFormController.clear();
                    _selectedIndex.value = -1;
                  },
                  child: const Text("Clear"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
