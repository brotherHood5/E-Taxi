// import 'package:flutter/material.dart';
// import 'package:grab_clone/widgets/search_text_field.dart';
// import 'package:grab_clone/widgets/source_text_field.dart';

// const double _kAppBarHeight = 130.0;

// class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
//   const SearchAppBar({super.key, this.height});

//   final double? height;

//   @override
//   State<SearchAppBar> createState() => _SearchAppBarState();

//   @override
//   Size get preferredSize => Size.fromHeight(height ?? _kAppBarHeight);
// }

// class _SearchAppBarState extends State<SearchAppBar> {
//   final TextEditingController sourceLocationController;
//   final TextEditingController destinationController;
//   bool isSrcSelected = false;
//   bool isDesSelected = true;

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       toolbarHeight: widget.height ?? _kAppBarHeight,
//       leading: Container(
//         padding:
//             const EdgeInsets.only(top: 8.0, left: 8.0, right: 0, bottom: 8.0),
//         alignment: Alignment.topCenter,
//         child: const BackButton(),
//       ),
//       titleSpacing: 0,
//       title: Container(
//         margin: EdgeInsets.only(right: 16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: () => setState(() {
//                 debugPrint('isSourceSelected: $isSrcSelected');
//                 isSrcSelected = true;
//                 isDesSelected = false;
//               }),
//               child: SearchTextField(),
//             ),
//             // SizedBox(width: 16),
//             // GestureDetector(
//             //   onTap: () => setState(() {
//             //     debugPrint('isSourceSelected: $isDesSelected');
//             //     isDesSelected = true;
//             //     isSrcSelected = false;
//             //   }),
//             //   child: SearchTextField(
//             //     isSelected: isDesSelected,
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
