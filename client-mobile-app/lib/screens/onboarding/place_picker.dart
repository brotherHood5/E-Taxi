import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class PlacePicker extends StatefulWidget {
  const PlacePicker({super.key});

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> with OSMMixinObserver {
  late TextEditingController textEditingController = TextEditingController();

  final PickerMapController _pickerMapController = PickerMapController(
    initMapWithUserPosition: UserTrackingOption(),
  );

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    _pickerMapController.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    textEditingController.removeListener(textOnChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
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
                    TopSearchWidget()
                  ],
                ),
              ),
              bottomWidgetPicker: Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(children: [
                      ElevatedButton(
                        onPressed: () async {
                          GeoPoint p = await _pickerMapController
                              .selectAdvancedPositionPicker();
                          print(p);
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ]),
                  ],
                ),
                // child: FloatingActionButton(
                //   onPressed: () async {
                //     GeoPoint p =
                //         await _pickerMapController.selectAdvancedPositionPicker();
                //     print(p);
                //   },
                //   child: const Icon(Icons.arrow_forward),
                // )),
              ),
            )));
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    print("Map ready");
  }
}

class TopSearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopSearchWidgetState();
}

class _TopSearchWidgetState extends State<TopSearchWidget> {
  late PickerMapController controller;
  ValueNotifier<GeoPoint?> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  late StreamController<List<SearchInfo>> streamSuggestion = StreamController();
  late Future<List<SearchInfo>> _futureSuggestionAddress;
  String oldText = "";
  Timer? _timerToStartSuggestionReq;
  final Key streamKey = const Key("streamAddressSug");

  @override
  void initState() {
    super.initState();
    controller = CustomPickerLocation.of(context);
    controller.searchableText.addListener(onSearchableTextChanged);
  }

  void onSearchableTextChanged() async {
    final v = controller.searchableText.value;
    if (v.length > 3 && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq!.isActive) {
        _timerToStartSuggestionReq!.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        await suggestionProcessing(v);
        timer.cancel();
      });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: 5,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  void dispose() {
    controller.searchableText.removeListener(onSearchableTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifierAutoCompletion,
      builder: (ctx, isVisible, child) {
        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 500,
          ),
          height: isVisible ? MediaQuery.of(context).size.height / 4 : 0,
          child: Card(
            child: child!,
          ),
        );
      },
      child: StreamBuilder<List<SearchInfo>>(
        stream: streamSuggestion.stream,
        key: streamKey,
        builder: (ctx, snap) {
          if (snap.hasData) {
            return ListView.builder(
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(
                    snap.data![index].address.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  onTap: () async {
                    /// go to location selected by address
                    controller.goToLocation(
                      snap.data![index].point!,
                    );

                    /// hide suggestion card
                    notifierAutoCompletion.value = false;
                    await reInitStream();
                    FocusScope.of(context).requestFocus(
                      FocusNode(),
                    );
                  },
                );
              },
              itemCount: snap.data!.length,
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
