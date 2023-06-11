import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:grab_clone/constants.dart';
import 'package:grab_clone/screens/search_location.dart';
import 'package:grab_clone/widgets/location_list_item.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/skeletons/skeleton_location_list_item.dart';

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
    // Simulating a delay to fetch the data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Populate the items list with the fetched data
        items = locations;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Expanded(
                  child: Container(
                padding: const EdgeInsets.only(top: layoutXXLarge),
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
          Container(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22 - kToolbarHeight / 2,
            left: layoutMedium,
            right: layoutMedium,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchLocationScreen(),
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
              },
              child: Container(
                  height: kToolbarHeight,
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
                      Text("home_search_bar_hint".tr(),
                          style: theme.textTheme.titleLarge!
                              .copyWith(color: Colors.grey[500])),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
