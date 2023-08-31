import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';

import '../../model/BookingReq.dart';
import '../../model/Location.dart';

class BookingFormController {
  VoidCallback clear = () {};
  BookingReq bookingReq = BookingReq(
      destAddr: Location(),
      phoneNumber: '',
      pickupAddr: Location(),
      status: '',
      vehicleType: '');

  void dispose() {}
}

class BookingForm extends StatefulWidget {
  final Function onPhoneNumberChanged;
  // final Function() saveChildCallback;

  final BookingFormController controller;

  const BookingForm({
    Key? key,
    required this.onPhoneNumberChanged,
    required this.controller,
  }) : super(key: key);
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  void saveChildCallback() {
    print("submit");
  }

  String vehicleType = 'Bike';
  TextEditingController phoneController = TextEditingController();

  TextEditingController pickupNoText = TextEditingController();
  TextEditingController pickupStreetText = TextEditingController();
  TextEditingController pickupWardText = TextEditingController();
  TextEditingController pickupDistrictText = TextEditingController();
  TextEditingController pickupCityText = TextEditingController();

  TextEditingController destNoText = TextEditingController();
  TextEditingController destStreetText = TextEditingController();
  TextEditingController destWardText = TextEditingController();
  TextEditingController destDistrictText = TextEditingController();
  TextEditingController destCityText = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.text = "0972360214";
    BookingFormController controller = widget.controller;
    controller.clear = () => setState(() => phoneController.text = "");
  }

  @override
  void dispose() {
    EasyDebounce.cancel("phoneController");
    phoneController.dispose();
    pickupNoText.dispose();
    pickupStreetText.dispose();
    pickupWardText.dispose();
    pickupDistrictText.dispose();
    pickupCityText.dispose();
    destNoText.dispose();
    destStreetText.dispose();
    destWardText.dispose();
    destDistrictText.dispose();
    destCityText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0), // Customize the padding value
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Customize background color
        borderRadius: BorderRadius.circular(10.0), // Customize border radius
      ),
      child: Form(
        child: Column(
          children: [
            // From and To fields for the first row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    onChanged: (text) {
                      EasyDebounce.debounce(
                          'phoneController', // <-- An ID for this particular throttler
                          const Duration(
                              milliseconds: 500), // <-- The throttle duration
                          () => widget.onPhoneNumberChanged(
                              text) // <-- The target method
                          );
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Vehicle type radio buttons
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: Text('Bike'),
                    value: '2 ',
                    groupValue:
                        vehicleType, // Use the variable that holds the selected value
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        vehicleType = value as String;
                        print(vehicleType); // Update the selected value
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Text('4-Car'),
                    value: '4',
                    groupValue:
                        vehicleType, // Use the variable that holds the selected value
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        vehicleType =
                            value as String; // Update the selected value
                        print(vehicleType); // Update the selected value
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Text('7-Car'),
                    value: '7',
                    groupValue:
                        vehicleType, // Use the variable that holds the selected value
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        vehicleType =
                            value as String; // Update the selected value
                        print(vehicleType); // Update the selected value
                      });
                    },
                  ),
                ),
              ],
            ),
            // From and To fields for the second row

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickupNoText,
                    decoration: InputDecoration(
                      labelText: 'Pick up Home No.',
                      hintText: 'Pick up Home No.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destNoText,
                    decoration: InputDecoration(
                      labelText: 'Destination Home No.',
                      hintText: 'Destination Home No.',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickupStreetText,
                    decoration: InputDecoration(
                      label: Text("Pick up Street"),
                      hintText: 'Pick up street',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destStreetText,
                    decoration: InputDecoration(
                      label: Text("Destination Street"),
                      hintText: 'Destination Street   ',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickupWardText,
                    decoration: InputDecoration(
                      label: Text("Pick up Ward"),
                      hintText: 'Pick up ward',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destWardText,
                    decoration: InputDecoration(
                      label: Text("Destination Ward"),
                      hintText: 'Destination ward',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickupDistrictText,
                    decoration: InputDecoration(
                      label: Text("Pick up District"),
                      hintText: 'Pick up district',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destDistrictText,
                    decoration: InputDecoration(
                      label: Text("Destination District"),
                      hintText: 'Destination district',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickupCityText,
                    decoration: InputDecoration(
                      label: Text("Pick up City"),
                      hintText: 'Pick up city',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destCityText,
                    decoration: InputDecoration(
                      label: Text("Destination City"),
                      hintText: 'Destination city',
                    ),
                  ),
                ),
              ],
            ),

            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           // Handle the Cancel button action
            //           Navigator.of(context).pop(); // Close the dialog
            //         },
            //         child: Text('Cancel'),
            //       ),
            //     ),
            //     SizedBox(width: 10), // Add some space between buttons
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           String name = nameController.text;
            //           String phone = phoneController.text;
            //           String from = fromController.text;
            //           String to = toController.text;

            //           print('Name: $name');
            //           print('Phone: $phone');
            //           print('From: $from');
            //           print('To: $to');
            //           print('Vehicle Type: $vehicleType');
            //         },
            //         child: Text('Submit'),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
