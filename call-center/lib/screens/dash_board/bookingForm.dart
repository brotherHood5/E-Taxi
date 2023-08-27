import 'package:flutter/material.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({Key? key}) : super(key: key);
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  String vehicleType = 'Bike';
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500, // Set the desired width
      height: 500, // Set the desired height
      child: Form(
        child: Column(
          children: [
            // From and To fields for the first row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter customer name',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Vehicle type radio buttons
            // Vehicle type radio buttons
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: Text('Bike'),
                    value: 'Bike',
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
                    title: Text('Car'),
                    value: 'Car',
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
                    title: Text('Truck'),
                    value: 'Truck',
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
                    decoration: InputDecoration(
                      labelText: 'From',
                      hintText: 'Enter your location',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'To',
                      hintText: 'Enter your destination',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 200.0),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the Cancel button action
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 10), // Add some space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      String name = nameController.text;
                      String phone = phoneController.text;
                      String from = fromController.text;
                      String to = toController.text;

                      print('Name: $name');
                      print('Phone: $phone');
                      print('From: $from');
                      print('To: $to');
                      print('Vehicle Type: $vehicleType');
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
