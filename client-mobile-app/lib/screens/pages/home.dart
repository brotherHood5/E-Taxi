import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:grab_clone/api/SocketApi.dart';
import 'package:grab_clone/constants.dart';
import 'package:grab_clone/models/Booking.dart';
import 'package:grab_clone/screens/book/driver_tracking.dart';
import 'package:grab_clone/widgets/location_list_item.dart';
import 'package:grab_clone/widgets/vehicle_chosen_button.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/helper.dart';
import '../../models/BookingStatus.dart';
import '../../widgets/skeletons/skeleton_location_list_item.dart';
import '../place_picker.dart';

class Location {
  final String name;
  final String address;

  Location({required this.name, required this.address});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.scrollController}) : super(key: key);
  final ScrollController? scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Location> items = [];
  List<Location> locations = [
    Location(
      name: "Location 1",
      address: "Address 1",
    ),
    Location(
      name: "Location 2",
      address: "Address 2",
    ),
    Location(
      name: "Location 3",
      address: "Address 3",
    ),
    Location(
      name: "Location 4",
      address: "Address 4",
    ),
    Location(
      name: "Location 5",
      address:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin fringilla elit id lacinia consectetur. Vivamus tempor tellus vitae purus feugiat, non lacinia velit feugiat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Cras ultricies semper arcu. Nulla sed velit pretium, posuere arcu id, porta turpis. Maecenas dapibus turpis ut magna facilisis, nec consequat neque ",
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        items = locations;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    SocketApi.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: theme.primaryColor.withOpacity(.7),
                height: MediaQuery.of(context).size.height * 0.22,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: kToolbarHeight,
                        left: layoutMedium + layoutSmall,
                        right: layoutMedium + layoutSmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("home_top_text_1".tr(),
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: layoutSmall),
                        Text("home_top_text_2".tr(),
                            style: theme.textTheme.bodyMedium)
                      ],
                    )),
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: layoutXXLarge + layoutMedium,
                    left: layoutMedium,
                    right: layoutMedium),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      VehicleChosenButton(
                        image: "assets/images/motorbike.png",
                        title: "Xe máy",
                        vehicleType: "2",
                      ),
                      VehicleChosenButton(
                        image: "assets/images/car.png",
                        title: "4 chỗ",
                        vehicleType: "4",
                      ),
                      VehicleChosenButton(
                        image: "assets/images/van.png",
                        title: "7 chỗ",
                        vehicleType: "7",
                      ),
                    ]),
              ),
              const SizedBox(height: layoutSmall),
              Expanded(
                  child: Container(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: isLoading
                          ? ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (_, i) {
                                return Shimmer.fromColors(
                                  baseColor: baseLoadingColor,
                                  highlightColor: highlightLoadingColor,
                                  child: const SkeletonLocationListItem(),
                                );
                              },
                              separatorBuilder: (_, __) => Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: layoutMedium),
                                color: Colors.grey.withOpacity(.4),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (_, i) {
                                return LocationListItem(
                                    onTap: () => {debugPrint(items[i].name)},
                                    title: items[i].name,
                                    subtitle: items[i].address);
                              },
                              separatorBuilder: (_, __) => Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: layoutMedium),
                                color: Colors.grey.withOpacity(.4),
                              ),
                            ),
                    ),
                    const SizedBox(height: layoutMedium),
                  ]),
                ),
              ))
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22 -
                (kToolbarHeight + layoutMedium) / 2,
            left: layoutMedium,
            right: layoutMedium,
            child: GestureDetector(
              onTap: () async {
                GeoPoint? pickupGeo = await getPickupGeoPoint();
                var p = await navigator.push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PlacePicker(
                          isPickUpAddr: true,
                          initPosition: pickupGeo ?? pickupGeo,
                        ),
                    transitionDuration: shortDuration,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    }));
                if (p != null) {
                  await savePickupGeoPoint(p);
                  if (!mounted) return;
                  setState(() {});
                }
              },
              child: Container(
                  height: kToolbarHeight + layoutMedium,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(borderRadiusSmall),
                  ),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: layoutMedium),
                        child: Icon(
                          Icons.location_on,
                          color: theme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                            future: getPickupAddress(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                      right: layoutMedium),
                                  child: Text(snapshot.data.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 2,
                                      style: theme.textTheme.titleLarge!
                                          .copyWith(color: Colors.black)),
                                );
                              }
                              return Text("home_search_bar_hint".tr(),
                                  style: theme.textTheme.titleLarge!
                                      .copyWith(color: Colors.grey[500]));
                            }),
                      ),
                    ],
                  )),
            ),
          ),
          FutureBuilder<BookingModel?>(
              future: getCurrentBooking(),
              builder: (context, snapshot) {
                log("snapshot.hasData: ${snapshot.hasData}",
                    name: "HomeScreen");
                if (snapshot.hasData) {
                  SocketApi().ins.on("booking_updated", (data) async {
                    if (data == null) {
                      return;
                    }
                    BookingModel req = BookingModel.fromMap(data);
                    switch (req.status) {
                      case BookingStatus.FAILED:
                        EasyLoading.showError(
                            "Không tìm được tài xế. Thử lại sau");
                        await clearCurrentBooking();
                        setState(() {
                          SocketApi().ins.off("booking_updated");
                        });
                        break;
                      case BookingStatus.DONE:
                        await clearCurrentBooking();
                        await EasyLoading.showInfo("Đã hoàn thành chuyến đi");
                        setState(() {
                          SocketApi().ins.off("booking_updated");
                        });
                        break;
                    }
                  });

                  return Positioned(
                      left: layoutMedium,
                      right: layoutMedium,
                      bottom: layoutMedium,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverTrackingScreen()))
                              .then((value) => setState(() {}));
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(borderRadiusSmall),
                                side: BorderSide(
                                    color: Colors.grey.withOpacity(.4)))),
                        child: Text("Theo dõi vị trí tài xế",
                            style: Theme.of(context).textTheme.titleLarge!),
                      ));
                }
                return const SizedBox();
              })
        ],
      ),
    );
  }
}
