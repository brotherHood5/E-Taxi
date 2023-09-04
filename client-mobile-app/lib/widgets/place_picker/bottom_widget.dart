import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../constants.dart';

class BottomPlacePickerWidget extends StatefulWidget {
  final bool isPickUpAddr;
  const BottomPlacePickerWidget({super.key, this.isPickUpAddr = false});

  @override
  State<BottomPlacePickerWidget> createState() =>
      _BottomPlacePickerWidgetState();
}

class _BottomPlacePickerWidgetState extends State<BottomPlacePickerWidget> {
  late NavigatorState navigator;
  late PickerMapController _pickerMapController;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    navigator = Navigator.of(context);
    _pickerMapController = CustomPickerLocation.of(context);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: () async {
              GeoPoint p =
                  await _pickerMapController.selectAdvancedPositionPicker();
              navigator.pop(p);
            },
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
              widget.isPickUpAddr ? "Xác nhận điểm đón" : "Xác nhận điểm đến",
              style: theme.textTheme.titleMedium!.merge(const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }
}
