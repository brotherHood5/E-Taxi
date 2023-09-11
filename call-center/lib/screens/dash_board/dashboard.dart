import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'booking_form.dart';
import '../../constant.dart';
import '../../model/BookingReq.dart';
import '../../model/TopAddress.dart';
import '../../model/TopHistory.dart';

class Dashboard extends StatefulWidget {
  static const String route = '/dashboard';

  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final BookingFormController _bookingFormController = BookingFormController();
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(-1);

  ValueNotifier<String> phoneNumber = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
  }

  Future<void> _bookRide(BookingReq req) async {
    String body = req.toJson();
    if (req.pickupAddr.id != null && req.destAddr.id != null) {
      body = json.encode({
        ...req.toMap(),
        "pickupAddr": req.pickupAddr.id,
        "destAddr": req.destAddr.id,
      });
    }

    final res = await http.post(Uri.parse(BOOK_RIDE_URL),
        headers: {
          "Content-Type": "application/json",
        },
        body: body);
    if (res.statusCode == 200) {
    } else {
      throw Exception("Error");
    }
  }

  Future<List<TopAddress>> _getTop5Address(String phoneNumber) async {
    final res = await http.get(
      Uri.parse(TOP5_ADDRESS_URL)
          .replace(queryParameters: {"phoneNumber": phoneNumber}),
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

  Future<List<TopHistory>> _getTopHistory(String phoneNumber) async {
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
    phoneNumber.value = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                          child: ValueListenableBuilder<String>(
                            valueListenable: phoneNumber,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              return FutureBuilder<List<TopAddress>>(
                                  future: _getTop5Address(value),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return DataTable(
                                          headingRowColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) =>
                                                      Colors.grey.shade200),
                                          columns: const [
                                            DataColumn(label: Text("No")),
                                            DataColumn(
                                                label: Text("Top address")),
                                            DataColumn(label: Text("Counts")),
                                          ],
                                          rows: List.generate(
                                              snapshot.data!.length, (index) {
                                            var data = snapshot.data![index];

                                            var addr = data.address;
                                            List<String?> array = [
                                              addr?.homeNo,
                                              addr?.street,
                                              addr?.ward,
                                              addr?.district,
                                              addr?.city
                                            ]
                                                .where((element) =>
                                                    element != null &&
                                                    element.isNotEmpty)
                                                .toList();
                                            String? formattedAddr =
                                                array.join(", ");

                                            return DataRow(cells: [
                                              DataCell(Text("${index + 1}")),
                                              DataCell(Text(formattedAddr)),
                                              DataCell(
                                                  Text(data.count.toString())),
                                            ]);
                                          }));
                                    }
                                    if (snapshot.hasError) {
                                      return DataTable(
                                        headingRowColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    Colors.grey.shade200),
                                        columns: const [
                                          DataColumn(label: Text("No")),
                                          DataColumn(
                                              label: Text("Top address")),
                                          DataColumn(label: Text("Counts")),
                                        ],
                                        rows: const [],
                                      );
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // To make sure DataTable takes up the available space
                          child: ValueListenableBuilder<String>(
                            valueListenable: phoneNumber,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              return FutureBuilder<List<TopHistory>>(
                                  future: _getTopHistory(value),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ValueListenableBuilder(
                                        valueListenable: _selectedIndex,
                                        builder: (BuildContext context,
                                            dynamic value, Widget? child) {
                                          return DataTable(
                                              showCheckboxColumn: false,
                                              headingRowColor:
                                                  MaterialStateProperty
                                                      .resolveWith((states) =>
                                                          Colors.grey.shade200),
                                              columns: const [
                                                DataColumn(label: Text("No")),
                                                DataColumn(
                                                    label: Text("Pickup Addr")),
                                                DataColumn(
                                                    label: Text("Dest Addr")),
                                                DataColumn(
                                                    label: Text("Status")),
                                                DataColumn(
                                                    label:
                                                        Text("Booking Time")),
                                              ],
                                              rows: List.generate(
                                                  snapshot.data!.length,
                                                  (index) {
                                                var data =
                                                    snapshot.data![index];

                                                var pickupAddr =
                                                    data.pickupAddr;
                                                List<String?> pickupAddrList = [
                                                  pickupAddr?.homeNo,
                                                  pickupAddr?.street,
                                                  pickupAddr?.ward,
                                                  pickupAddr?.district,
                                                  pickupAddr?.city,
                                                ]
                                                    .where((element) =>
                                                        element != null &&
                                                        element.isNotEmpty)
                                                    .toList();

                                                var destAddr = data.destAddr;
                                                List<String?> destAddrList = [
                                                  destAddr?.homeNo,
                                                  destAddr?.street,
                                                  destAddr?.ward,
                                                  destAddr?.district,
                                                  destAddr?.city,
                                                ]
                                                    .where((element) =>
                                                        element != null &&
                                                        element.isNotEmpty)
                                                    .toList();

                                                return DataRow(
                                                    color: MaterialStateColor
                                                        .resolveWith((states) =>
                                                            value == index
                                                                ? Colors.orange
                                                                    .shade200
                                                                : Colors.white),
                                                    onSelectChanged:
                                                        (selected) {
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
                                                      DataCell(Text(
                                                          pickupAddrList
                                                              .join(", "))),
                                                      DataCell(Text(destAddrList
                                                          .join(", "))),
                                                      DataCell(Text(
                                                          data.status == null
                                                              ? ""
                                                              : data.status
                                                                  .toString())),
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
                                        showCheckboxColumn: false,
                                        headingRowColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    Colors.grey.shade200),
                                        columns: const [
                                          DataColumn(label: Text("No")),
                                          DataColumn(
                                              label: Text("Pickup Addr")),
                                          DataColumn(label: Text("Dest Addr")),
                                          DataColumn(
                                              label: Text("Booking Time")),
                                        ],
                                        rows: const [],
                                      );
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  });
                            },
                          ),
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
                      var req = _bookingFormController.getBookingReq();
                      print(req.toString());

                      if (req.isValidBookingReq()) {
                        await _bookRide(req);
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (_) => const AlertDialog(
                                  title: Text('Success'),
                                  content: Text('Request has been sent'),
                                ));
                        _bookingFormController.clear();
                        setState(() {
                          phoneNumber.value = "";
                        });
                      } else {
                        await showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
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
