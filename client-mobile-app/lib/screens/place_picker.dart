import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/widgets/place_picker/bottom_widget.dart';

import '../widgets/place_picker/top_search.dart';

class PlacePicker extends StatefulWidget {
  final bool isPickUpAddr;
  final GeoPoint? initPosition;
  const PlacePicker({super.key, this.isPickUpAddr = false, this.initPosition});

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> with OSMMixinObserver {
  late TextEditingController textEditingController = TextEditingController();

  late final PickerMapController _pickerMapController;

  @override
  void initState() {
    super.initState();
    if (widget.initPosition == null) {
      _pickerMapController = PickerMapController(
        initMapWithUserPosition: UserTrackingOption(),
      );
    } else {
      _pickerMapController = PickerMapController(
        initPosition: widget.initPosition!,
      );
    }

    _pickerMapController.addObserver(this);
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    _pickerMapController.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    textEditingController.removeListener(textOnChanged);
    _pickerMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Scaffold(
        body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CustomPickerLocation(
              controller: _pickerMapController,
              pickerConfig: CustomPickerLocationConfig(
                advancedMarkerPicker: MarkerIcon(
                  iconWidget: Image.asset(
                    "assets/images/dest_marker.png",
                    scale: 0.1,
                    width: 100,
                    height: 100,
                  ),
                ),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(),
                ),
                zoomOption: const ZoomOption(
                    initZoom: 16, minZoomLevel: 13, maxZoomLevel: 19),
              ),
              topWidgetPicker: Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 8,
                  right: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              suffix: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: textEditingController,
                                builder: (ctx, text, child) {
                                  if (text.text.isNotEmpty) {
                                    return child!;
                                  }
                                  return const SizedBox.shrink();
                                },
                                child: InkWell(
                                  focusNode: FocusNode(),
                                  onTap: () {
                                    textEditingController.clear();
                                    _pickerMapController.setSearchableText("");
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                ),
                              ),
                              focusColor: Colors.orange,
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: "Tìm địa điểm (nhập lớn hơn 3 ký tự)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const TopSearchWidget()
                  ],
                ),
              ),
              bottomWidgetPicker: BottomPlacePickerWidget(
                isPickUpAddr: widget.isPickUpAddr,
              ),
            )));
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    await _pickerMapController.advancedPositionPicker();
  }
}
